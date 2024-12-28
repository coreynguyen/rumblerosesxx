gc()
clearlistener()

try(DestroyDialog RRXX_TOOL)catch(RRXX_TOOL)
rollout RRXX_TOOL "RRXX Tool v0.1b"width:200 height:530 (
	
	local skinON = false
	local skelON = false
	local buildON = true
	local mshSmooth = false
	local onlySelection = false
	local updateVerts = true
	local updateTverts = false
	local updateNorms = false
	local updateBound = true
	local updateWeights = false
	local onlySelectionWarning = false
	local skinONWarning = false
	
	group "Load File" (
		editText edt1 "" width:170 height:16
		button btn1 "Browse" align:#left
		)
	group "Import" (
		button btn2 "Import"
		checkbox chk0 "Clear Scene" checked:true
		checkbox chk1 "Geometry" checked:buildON
		checkbox chk2 "Skeleton" checked:skelON
		checkbox chk3 "Vertex Weights" checked:skinON
		)
	group "Injection" (
		button btn3 "Update File"
		checkbox chk4 "By Vertex Selection" checked:onlySelection
		checkbox chk5 "Vertices" checked:updateVerts
		checkbox chk6 "Texture Vertices" checked:updateTverts
		checkbox chk7 "Vertex Normals" checked:updateNorms
		checkbox chk8 "Vertex Weights" checked:updateWeights
		checkbox chk9 "Bound Sphere" checked:updateBound
		)
	group "Packing" (
		button btn4 "Create tex File"
		button btn5 "Create pac File"
		)
	group "UnPacking" (
		button btn4b "Unpack tex File"
		button btn5b "Unpack pac File"
		)
	group "About" (
		label lb3 "Written By:" align:#left
		label lb4 "    Mario_Kart64n" align:#left
		hyperLink lb5 "    mariokart64n@gmail.com" address:"mailto:mariokart64n@gmail.com"
		label lb6 "Donate:" align:#left
		hyperLink lb7 "    Paypal" address:"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=coreynguyen%40gmail%2ecom&item_name=maxscript%20work&no_shipping=0&no_note=1&tax=0&currency_code=CAD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8"
		)
	

	local f,filen,mscale=1,geos=#(),hdr=#(),boneArray=#()

	struct _skeleton (
		bone_name="",
		bone_position=[0,0,0],
		bone_end=[0,0,0],
		bone_parent=-1,
		unknown=[0,0,0],
		bone_rotation=[0,0,0]
		)
	struct _object (
		vertex_count=0,
		element_count=0,
		bone_map=#(),
		num_bone_weights=0,
		group_index=0,
		unk10=0,
		vertex_offset=0,
		weight_offset=0,
		uvw_offset=0,
		unk14=0,
		name="",
		unk15=0,
		unk16=0,
		texture_count=0,
		texture_offset=0,
		element_offset=0,
		tvert_count=0,
		unk21=0,
		position=[0,0,0]
		)
	struct _texcontainer (
		name="",
		ext="",
		size=0,
		offset=0,
		flag=0
		)
	fn checkForLicSerStuckCleanBetaVirus = (
		-- https://knowledge.autodesk.com/support/3ds-max/troubleshooting/caas/sfdcarticles/sfdcarticles/Scene-file-crashes-corrupts-scene-data-gives-Script-Controller-error-or-no-longer-uses-the-Undo-function.html #3dsMax 
		if globalVars != undefined \
		and globalVars.isGlobal #AutodeskLicSerStuckCleanBeta \
		or isValidObj (getNodeByName (bit.intaschar(161) + bit.intaschar(161) + bit.intaschar(215) + bit.intaschar(253) + bit.intaschar(215) + bit.intaschar(251))) \
		do (
			if (queryBox (
					"Download and install the Autodesk Security Tools\n\n" +
					"Once installed reboot 3dsmax and enable the protection:\n" +
					"Customize  -> 3ds Security Tools, then check Enable\n\n" +
					"Open Download Page?"
					) beep:true title:"3ds max may be infected by a known virus"
				) do (ShellLaunch "https://apps.autodesk.com/3DSMAX/en/Detail/Index?id=7342616782204846316" "")
			)
		)
	fn getpadding num alignment = (
		(mod (alignment-(mod num alignment)) alignment)
		)
	fn readTecPack file = (
		local f = undefined, fsize = 0
		local cnt = 0, filename = "", p = 0
		local size = 0, addr = 0, fext = ""
		local s = undefined, spath = ""
		local i = 1, ii = 1
		

		if file == undefined do return false
		f = fopen file "rbS"
		if f == undefined do return false
		fsize = getFileSize file
		cnt = readlong f #unsigned
		--print cnt
		if ((cnt * 0x20) + 0x0C) > fsize \
		or readlong f #unsigned != 0x00000100 \
		or readlong f #unsigned != 0x00000000 \
		do (
			messagebox "Error Unable to Read Header"
			return false
			)
		p = 0x0C
		spath = (getFilenamePath file) + (getFilenameFile file) + "_textures"
		makeDir spath
		for i = 1 to cnt do (
			fseek f (p + 0x04) #seek_set
			filename = readstring f
			--print filename
			fseek f (getpadding (filename.count + 1) 0x10) #seek_cur
			fext = readstring f
			fseek f (getpadding (fext.count + 1) 0x04) #seek_cur
			size = readlong f #unsigned
			addr = readlong f #unsigned
			p = ftell f
			--format "%.%\n" filename fext
			if (addr + size) <= fsize do (
				fseek f addr #seek_set
				s = fopen (spath + "\\" + filename + "." + fext) "wbS"
				for ii = 1 to size do (
					writebyte s (readbyte f #unsigned) #unsigned
					)
				fclose s
				)
			)

		fclose f
		return true
		)
	fn writeTecPac file = (
		local files = #(), searchPath = "", i = 1
		local s = undefined, cur = 0, dosStr = ""
		local fsize = 0
		if file == undefined do return false
		searchPath = getFilenamePath file
		if doesFileExist searchPath == false do return false
		files = getFiles (searchPath + "*.dds")
		if filescount == 0 do return false
		s = fopen (searchPath + "tex_header.tmp") "wbS"
		writelong s files.count #unsigned
		writelong s 0x0100 #unsigned
		writelong s 0x0000 #unsigned
		writelong s 0x0010 #unsigned -- table Offset
		cur = (ftell s) + (0x20 * files.count)
		dosStr = "copy \"" + searchPath + "tex_header.tmp\" /b + "
		for i = 1 to files.count do (
			fsize = getFileSize files[i]
			writeFixedString s 0x10 (getFilenameFile files[i])
			writeFixedString s 0x04 "dds"
			writelong s fsize #unsigned
			writelong s cur #unsigned
			writelong s 0x00 #unsigned
			cur += fsize
			dosStr += "\""+ files[i] + "\" /b "
			if i != files.count do (
				dosStr += "+ "
				)
			)
		fclose s
		dosStr += "\""+ searchPath + "TexPack.tex\""
		--DOSCommand dosStr
		HiddenDOSCommand dosStr
		deleteFile (searchPath + "tex_header.tmp")
		return true
		)
	fn extractPach file = (
		local f = undefined, i = 1, cnt = 0
		local info = 0, addr = 0, size = 0
		local s = undefined, p = 0, fpath = ""
		local fname = "", spath = "", ii = 1
		local pad = "0000000000", num = ""
		local fsize = 0, fext = ".bin", magic = 0
		if file == undefined do return false
		f = fopen file "rbS"
		if f == undefined do return false
		fsize = getFileSize file
		if fsize == 0 do return false
		if (readlong f #unsigned) != 0x48434150 do (
			messagebox "Error file type not PACH"
			return false
			)
		fpath = getFilenamePath file
		fname = getFilenameFile file
		spath = fpath + fname + "_unpacked"
		makeDir spath
		cnt = readlong f #unsigned
		p = (cnt * 0x0C) + 0x08
		for i = 1 to cnt do (
			fseek f (((i - 1) * 0x0C) + 0x08) #seek_set
			info = readlong f #unsigned
			addr = readlong f #unsigned
			size = readlong f #unsigned
			fseek f (p + addr) #seek_set
			if size > 0 do (
				pad = "0000000000"
				num = info as string
				fext = ".bin"
				magic = readlong f #unsigned
				fext = (
					case magic of (
						0x594F424A: ".yobj" --yukes object
						0x48434150: ".pach" --pack archive
						0x20455042: ".bpe" --encrypted pack binary?
						default: (
							if bit.and magic 0xFF == 0x3B then (
								fext = ".txt"
								)
							else (
								fext
								)
							)
						)
					)
				fseek f (p + addr) #seek_set
				s = fopen (spath + "\\" + ((substring pad 1 (pad.count - num.count)) + num) + fext) "wbS"
				if (p + addr + size) <= fsize do (
					for ii = 1 to size do (
						writebyte s (readbyte f #unsigned) #unsigned
						)
					)
				fclose s
				)
			)
		fclose f
		return true
		)
	fn writePach searchPath = (
		local files = #(), tmp = #(), i = 1, fext = ""
		local s = undefined, cur = 0, dosStr = ""
		local fsize = 0, num = 0
		if doesFileExist searchPath == false do return false
		tmp = getFiles (searchPath + "*.*")
		for i = 1 to tmp.count do (
			fext = getFilenameType tmp[i]
			if findItem #(".pac",".PAC",".tmp",".TMP",".dds") fext == 0 do (
				append files tmp[i]
				)
			)
		if tmp.count == 0 do return false
		sort files
		s = fopen (searchPath + "header.tmp") "wbS"
		if s == undefined do return false
		writelong s 0x48434150 #unsigned -- PACH
		writelong s files.count #unsigned
		dosStr = "copy \"" + searchPath + "header.tmp\" /b + "
		for i = 1 to files.count do (
			fsize = getFileSize files[i]
			num = try(execute (getFilenameFile files[i]))catch(undefined)
			if num == undefined do num = i
			writelong s num #unsigned
			writelong s cur #unsigned
			writelong s fsize #unsigned
			cur += fsize
			dosStr += "\""+ files[i] + "\" /b "
			if i != files.count do (
				dosStr += "+ "
				)
			)
		fclose s
		dosStr += "\""+ searchPath + "filepack.pac\""
		DOSCommand dosStr
		deleteFile (searchPath + "header.tmp")
		return true
		)
	fn whyL val = (
		local str = val as string
		local i=0,new=""
		local c = #("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","a","b","c","d","e","f")
		for i = 1 to str.count do (
			if findItem c str[i] != 0 do (
				new += str[i]
				)
			)
		return new
		)
	fn RH2LH corrd = (
		global mscale
		return ([corrd.x,corrd.z,-corrd.y]*mscale)
		)
	fn readBElong fstream = (bit.swapBytes (bit.swapBytes (readlong fstream #unsigned) 1 4) 2 3)
	fn readBEshort fstream = (bit.swapBytes (readshort fstream #unsigned) 1 2)
	fn readBEfloat fstream = (bit.intAsFloat (bit.swapBytes (bit.swapBytes (readlong fstream #unsigned) 1 4) 2 3))
	fn writeBElong fstream intv = (
		writelong fstream (bit.swapBytes (bit.swapBytes intv 1 4) 2 3) #unsigned
		)
	fn writeBEfloat fstream floatp = (
		writelong fstream (bit.swapBytes (bit.swapBytes (bit.floatAsint floatp) 1 4) 2 3) #unsigned
		)
	fn writeFixedString bstream len str = (
		local i
		for i = 1 to len do (
			if i <= str.count then (
				writebyte bstream (bit.CharAsInt str[i]) #unsigned
				)
			else (
				writebyte bstream 0x00
				)
			)
		)
	fn getNormals obj = (
		local normMod = Edit_Normals()
		local my_verts = #{};my_verts.count = (getNumVerts obj)
		local my_normals = #()
		local i=0,x=0,s=#()
		s = selection
		s = for i = 1 to selection.count collect (selection[i])
		select obj
		addmodifier obj normMod
		for i = 1 to (getNumVerts obj) do (
			append my_normals (getNormal obj i)
			)
		for i = 1 to (getNumFaces obj) do (
			face = getFace obj i
			for x = 1 to 3 do (
				if my_verts[(face[x])] == false do (
					norm = normMod.GetNormalID i x
					my_normals[(face[x])] = normMod.GetNormal norm
					my_verts[(face[x])] = true
					)
				)
			)
		deletemodifier obj normMod
		select s
		return my_normals
		)
	fn findModifier obj class_ = (
		local i=0,idx = 0
		for i = 1 to obj.modifiers.count do (
			if (classof obj.modifiers[i] ==  class_) do (
				idx = i
				)
			)
		return idx
		)
	fn paddstring len instring = (
		local i,str=""
		instring=instring as string
		if instring.count <=len then (
			for i = 1 to (len-instring.count) do (
				str+="0"
				)
			str = (str+instring)
			)
		else (
			for i = 1 to len do (
				str+="0";str[i]=instring[i]
				)
			)
		return str
		)
	fn uppercase instring = (
		local upper, lower, outstring
		upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		lower="abcdefghijklmnopqrstuvwxyz"
		outstring=copy instring
		for i=1 to outstring.count do (
			j=findString lower outstring[i]
			if (j != undefined) do outstring[i]=upper[j]
			)
		outstring
		)
	fn readFixedString bstream fixedLen = (
		local str = ""
		for i = 1 to fixedLen do (
			str += bit.intAsChar (ReadByte bstream #unsigned)
			)
		str
		)
	fn enum_mat_component id = (
		case id of (
			0x05: #integer
			0x0A: #float
			0x0D: #color
			0x0F: #index
			0x10: #bool
			default: id
			)
		)
	fn buildskin msh boneArray boneidArray weightArray bone_limit = (
		global g,boneArray
		local i,j,d,skinmod,tmp=#(),find,x
		if weightArray.count!=0 do (
			skinMod = Skin ()
			addmodifier msh skinMod
			max modify mode
			modPanel.setCurrentObject skinMod
			skinMod.bone_Limit = bone_limit
			count = msh.numverts
			for i = 1 to boneArray.count do (
				skinOps.addBone skinMod boneArray[i] 0
				)
			d = dummy ()
			skinOps.addBone skinMod d 1	--skinOps.addBone skinMod boneArray[(boneArray.count)] 1
			d.name = "dummy bone" -- work around, assign all weights a value of 1.0 to the dummy bone
			select msh
			modPanel.setCurrentObject skinMod
			skinOps.SelectVertices skinMod #{1..(count)}
			skinOps.selectBone skinMod (boneArray.count+1)
			skinOps.SetWeight skinMod 1.0
			skinOps.RemoveZeroWeights skinMod
			select msh
			modPanel.setCurrentObject skinMod
			
			for i = 1 to count do (
				skinOps.ReplaceVertexWeights skinMod i boneidArray[i] weightArray[i]
				)
			select msh
			modPanel.setCurrentObject skinMod
			skinOps.SelectVertices skinMod #{1..(count)}
			skinOps.selectBone skinMod (boneArray.count+1)
			skinOps.SetWeight skinMod 0.0
			skinOps.RemoveZeroWeights skinMod
			delete d
			skinMod.filter_vertices = on
			skinOps.WeightTool skinMod
			)
		)
	fn triangle_strip fstream faceArray matidArray count face_add matid vertex_start = (
		global g
		local count,fa,fb,fc,x,y
		local face_flip = true
		local face_reset=true
		x=0;while x< count do (
			x+=1
			if face_reset == true then (
				x+=2
				face_reset=false
				face_flip = false
				append matidArray matid
				fa = ((readBEshort fstream)-vertex_start) + face_add
				fb = ((readBEshort fstream)-vertex_start) + face_add
				fc = ((readBEshort fstream)-vertex_start) + face_add
				if face_flip == true then (
					append faceArray [fa,fb,fc];face_flip=false
					)
				else(
					append faceArray [fa,fc,fb];face_flip=true
					)
				)
			else(
				fa = fb;fb = fc;fc = readBEshort fstream
				if fc<0xFFFF then (
					fc-= vertex_start
					fc += face_add
					append matidArray matid
					if face_flip == true then (
						append faceArray [fa,fb,fc];face_flip=false
						)
					else(
						append faceArray [fa,fc,fb];face_flip=true
						)
					)
				else(
					face_reset=true
					)
				)
			)
		)
	fn buildObj vertArray uvwArray faceArray matidArray = (
		local j,msh,mat
	-- 	mat=buildMat(matidArray)
		if vertArray.count>0 do (
			msh = mesh vertices:vertArray tverts:uvwArray faces:faceArray-- materialIDs:matidArray
			msh.displayByLayer = false
			msh.backfacecull = on
	-- 		msh.material = mat
			if uvwArray.count >0 do (
				msh.numTVerts = uvwArray.count
				buildTVFaces msh
				for j = 1 to uvwArray.count do setTVert msh j uvwArray[j]
				for j = 1 to faceArray.count do setTVFace msh j faceArray[j]
				)
	-- 		if faceArray.count == 0 do (
	-- 			convertTo msh PolyMeshObject
	-- 			)
			)
		msh
		)
	on RRXX_TOOL open do (
		checkForLicSerStuckCleanBetaVirus()
		)
	on chk1 changed state do (
		buildON = state
		)
	on chk2 changed state do (
		skelON = state
		)
	on chk3 changed state do (
		skinON = state
		if skinON == true do (
			if skinONWarning == false do (
				messagebox "Warning\nEnabling Skinning Will take longer to import"
				)
			skinONWarning = true
			)
		)
	on chk4 changed state do (
		onlySelection = state
		if onlySelection == true do (
			if onlySelectionWarning == false do (
				messagebox (
					"Add a Edit_Mesh Modifier\nhighlight the vertices you want to inject"
					)
				)
			onlySelectionWarning = true
			)
		)
	on chk5 changed state do (
		updateVerts = state
		print updateVerts
		if updateVerts == true do (
			updateBound = state
			chk9.state = state
			)
		)
	on chk6 changed state do (
		updateTverts = state
		)
	on chk7 changed state do (
		updateNorms = state
		)
	on chk8 changed state do (
		updateWeights = state
		)
	on chk9 changed state do (
		updateBound = state
		)
	on btn1 pressed do (
		edt1.text = (
			GetOpenFileName \
				caption:"Select a File" \
				types: "Yokes Object (*.yobj)|*.YOBJ|Yokes Object (*.ymxen)|*.YMXEN|texture pack (*.tex)|*.TEX|All files (*.*)|*.*|"
			) as string
		if edt1.text != undefined and (doesFileExist edt1.text) == true do (
			filen = edt1.text
			)
		)
	on btn2 pressed do (
			mscale = ( 1.0 / 2.54 ) * 10
			print filen
			if filen!=undefined and (doesFileExist filen) == true then (
				f = fopen filen "rb"
				fpath = getFilenamePath filen
				fext = uppercase(getFilenameType filen)
				if chk0.checked == true do (
					delete objects
					clearlistener()
					)
				filetype = readlong f #unsigned
				case filetype of (
					0x594F424A: ( -- YOBJ
						filesize = readBElong f -- end of header
						pos = ftell f -- start of data
						unk01 = readBElong f -- always 0?
						pof0_offset = readBElong f + pos
						unk02 = readBElong f -- always 0
						unk03 = readBElong f -- always 0
						mat_count = readBElong f
						mat_offset = readBElong f + pos
						skel_count = readBElong f
						tex_name_count = readBElong f
						skel_offset = readBElong f + pos
						tex_name_offset = readBElong f + pos
						obj_name_offset = readBElong f + pos
						obj_name_count = readBElong f
						unk07 = readBElong f -- always 0
						unk08 = readBElong f -- always 0
						
						format "Header Unknowns:\n\t[%, %, %, %, %]\n\n" \
							unk01 unk02 unk03 unk07 unk08
						fseek f tex_name_offset #seek_set
						texNames = for i = 1 to tex_name_count collect (
							readFixedString f 0x10
							)
						format "Texture Name Unknowns\n"
						fseek f obj_name_offset #seek_set
						objNames = for i = 1 to obj_name_count collect (
							n = readFixedString f 0x10
							unkA1 = readBElong f -- always 1
							unkA2 = readBElong f -- always 0
							unkA3 = readBElong f -- how may textures object uses
							unkA4 = readBElong f -- always 0
							format "\n[%, %, %, %]\n" unkA1 unkA2 unkA3 unkA4
							n
							)
						format "\nMesh Info Unknowns\n"
						fseek f mat_offset #seek_set
						objs = for i = 1 to mat_count collect (
							s = _object()
							hpos = ftell f
							s.vertex_count = readBElong f -- always 4
							s.element_count = readBElong f -- always 0
							s.bone_map = for x = 1 to (readBElong f) collect (
								readBElong f
								)
							fseek f ((20 - s.bone_map.count)*4) #seek_cur
							s.num_bone_weights = readBElong f
							s.group_index = readBElong f + 1
							s.unk10 = readBElong f -- always 1
							s.vertex_offset = readBElong f + pos
							s.weight_offset = readBElong f + pos
							s.uvw_offset = readBElong f + pos
							s.unk14 = readBElong f -- always 1
							s.name = readFixedString f 0x10
							s.name = i as string
							s.unk15 = readBElong f
							s.unk16 = readBElong f
							s.texture_count = readBElong f
							s.texture_offset = readBElong f + pos
							s.element_offset = readBElong f + pos
							s.tvert_count = readBElong f -- same as vertex count, maybe UV count?
							s.unk21 = readBElong f
							s.position = [(readfloat f),(readfloat f),(readfloat f),(readfloat f)]
				-- 			append geos (GeoSphere pos:(RH2LH([(s.position[1]),(s.position[2]),(s.position[3])])) radius:((s.position[4])*mscale))
				-- 				format "% [%] Distace: %\n" i ((s.position[4])*mscale) (distance [0,0,0] (RH2LH([(s.position[1]),(s.position[2]),(s.position[3])])))
				-- 			format "\t% [%, %, %, %, %]\n" i s.unk10 s.unk14 s.unk15 s.unk16 s.unk21
				-- 					print s
							append hdr hpos
							s
							)
						format "\n"
						fseek f skel_offset #seek_set
						skel = for i = 1 to skel_count collect (
							(_skeleton \
								bone_name:(readFixedString f 0x10) \
								bone_position:(([(readBEfloat f),(readBEfloat f),(readBEfloat f)]*mscale)+(readBEfloat f)) \
								bone_rotation:([(readBEfloat f),(readBEfloat f),(readBEfloat f)]+(readBEfloat f)) \
								bone_parent:(readBElong f + 1) \
								unknown:([(readBElong f),(readBElong f),(readBElong f)]) \
								bone_end:([(readfloat f),(readfloat f),(readfloat f),(readfloat f)]*mscale)
								)
							)
						
						
						if buildON == true do (
							boneArray = #()
					-- 		delete objects
							
								if skelON == true do (
								for i = 1 to skel.count do (
						-- 			d = Dummy()
									d = bonesys.createbone skel[i].bone_position (skel[i].bone_position+[0,0,1]) [0,1,0]
						-- 			d.name = skel[i].bone_name
									d.name = "Bone_"+(paddstring 4 i)
-- 									skel[i].bone_name = (paddstring 4 i) + " " +skel[i].bone_name
									tfm = (eulerangles (radtodeg (skel[i].bone_rotation[1])) (radtodeg (skel[i].bone_rotation[2])) (radtodeg (skel[i].bone_rotation[3]))) as matrix3
									tfm.row4 = skel[i].bone_position
									d.transform = tfm
									d.showLinks = d.showLinksOnly = true
									append boneArray d
									)
								for i = 1 to skel.count do (
									if skel[i].bone_parent != 0 then (
										boneArray[i].transform *= boneArray[(skel[i].bone_parent)].transform
										boneArray[i].parent = boneArray[(skel[i].bone_parent)]
										)
									else (
										boneArray[i].transform *= rotateXMatrix 270
										)
									)
								for i = 1 to skel.count do (
									bn = getNodeByName skel[i].bone_name
									if bn!=undefined do (
										select boneArray[i]
										delete selection[1]
										boneArray[i] = bn
										bn.name = "Bone_"+(paddstring 4 i)
										)
									)
								)
								for i = 1 to objs.count do ( --objs.count
								faceArray=#()
								matidArray = #()
								vertArray = #()
								uvwArray = #()
								boneidArray = #()
								weightArray = #()
								texIndex = #()
								texSpecIndex = #()
								texNormIndex = #()
								mat_index = 1
								face_pos = 1

										fseek f objs[i].vertex_offset #seek_set
										fseek f ((readBElong f)+pos) #seek_set
										vertpos = ftell f
										for v = 1 to objs[i].vertex_count do (
											position = RH2LH([(readBEfloat f),(readBEfloat f),(readBEfloat f)])
											normal = [(readBEfloat f),(readBEfloat f),(readBEfloat f)]
											normal = [(-normal.x),(-normal.z),(normal.y)]
											colour = color \
												(readbyte f #unsigned) \
												(readbyte f #unsigned) \
												(readbyte f #unsigned) \
												(readbyte f #unsigned)
											append vertArray position
											)
										fseek f objs[i].uvw_offset #seek_set
										for v = 1 to objs[i].vertex_count do (
											append uvwArray [(readBEfloat f),1-(readBEfloat f),0]
											)
										if uvwArray.count < vertArray.count do (
											for v = 1 to (vertArray.count - uvwArray.count) do (
												append uvwArray [0,0,0]
												)
											)
										if skinON == true do (
											fseek f objs[i].weight_offset #seek_set
											for v = 1 to objs[i].vertex_count do (
												bw = #()
												bi = #()
												for x = 1 to objs[i].num_bone_weights do (
													b1 = readlong f + 1
													w1 = readBEfloat f
													if b1 !=256 do (
														b1 = objs[i].bone_map[b1]
														append bi b1
														append bw w1
														)
													)
												append boneidArray bi
												append weightArray bw
												)
											)
										fseek f objs[i].element_offset #seek_set
											mehe = 0
				-- 							format "face [%]\n" objs[i].element_count
										for v = 1 to objs[i].element_count do (
											fseek f (objs[i].element_offset + (0x0C * (v-1))) #seek_set
											unk01 = readBElong f  -- always 6?
											face_count = readBElong f
												mehe += face_count
											face_offset = readBElong f + pos
											fseek f face_offset #seek_set
											triangle_strip f faceArray matidArray face_count 1 1 0
				-- 								format "f = %\n" face_count
											)
											
				-- 						format "fcount: % [%]\n" mehe ((ftell f)-objs[i].element_offset)
										face_pos += objs[i].vertex_count
										mat_index += 1
									
								m = buildObj vertArray uvwArray faceArray matidArray
											bonemap_str = "#("
											for v = 1 to objs[i].bone_map.count do (
												bonemap_str += objs[i].bone_map[v] as string
												if v != objs[i].bone_map.count then (
													bonemap_str += ","
													)
												else (
													bonemap_str += ")"
													)
												)
										m.name = (
											"Object" + (paddstring 3 i) + \
											" vert:" + (whyL vertpos) + \
											" tvert:" + (whyL objs[i].uvw_offset) + \
											" header:" + (whyL hdr[i]) + \
											" weights:" + (whyL objs[i].weight_offset) + \
											" bonemap:" + bonemap_str + \
											" bonelimit:" + (objs[i].num_bone_weights as string)
											)
										if skinON == true do (
											buildskin m boneArray boneidArray weightArray objs[i].num_bone_weights
											)
				-- 							geos[i].parent  = m
									)
							)
						for i = 1 to boneArray.count do (
							boneArray[i].name = skel[i].bone_name
							)
				-- 		$Text01.text = (
				-- 			"."+(filterstring fpath "X")[2]
				-- 			)
						)
					0x48434150: ( -- PACH
						struct _pach (
							type=0,
							offset=0,
							size=0
							)
						files = for i = 1 to (readlong f #unsigned) collect (
							(_pach \
								type:(readlong f #unsigned) \
								offset:(readlong f #unsigned) \
								size:(readlong f #unsigned)
								)
							)
						pos = ftell f
						makeDir (fpath+(getFilenameFile filen)+".0unpacked")
						for i = 1 to files.count do (
							close (createfile (fpath+(getFilenameFile filen)+".0unpacked"+"\\"+(paddstring 4 (files[i].type))+".dat"))
							s = fopen (fpath+(getFilenameFile filen)+".0unpacked"+"\\"+(paddstring 4 (files[i].type))+".dat") "wb"
							fseek f (files[i].offset + pos) #seek_set
							for x = 1 to files[i].size do (
								writebyte s (readbyte f #unsigned) #unsigned
								)
							fclose s
							)
						messagebox "Done!"
						)
					default: ( -- INVALID File Magic
						case fext of (
							".TEX": (
								count = filetype
								unk01 = readlong f #unsigned -- 256?
								unk02 = readlong f #unsigned
								offset = readlong f #unsigned
								for i = 1 to count do (
									fseek f (offset + (0x20 * (i-1))) #seek_set
									filename=readFixedString f 0x10
									fileext=readFixedString f 0x04
									filesize=readlong f #unsigned
									fileoffset=readlong f #unsigned
									fileflag=readlong f #unsigned
									fseek f fileoffset #seek_set
									close (createfile (fpath+filename+"."+fileext))
									s = fopen (fpath+filename+"."+fileext) "wb"
									for x = 1 to filesize do (
										writebyte s (readbyte f #unsigned) #unsigned
										)
									fclose s
									)
								)
							default: (
								print "unsupported file"
								)
							)
						)
					)
				format "Last Read @ 0x%\n" ((bit.intAsHex(ftell f))as string)
				print filen
				fclose f
				)
			else (
				Print "Aborted."
				)
			try ()
		catch (
			messagebox "I'm Sorry An Error Occured :("
			)
		)
	on btn3 pressed do (
		try (
			mscale = 2.54 / 10
			print filen
			if filen!=undefined and (doesFileExist filen) == true then (
				f = fopen filen "rb+"
				objs = selection
				for o in objs do (
					myMod = undefined
					if onlySelection == true do (
						if (classof o.modifiers[1]) != Edit_Mesh do (
							myMod = Edit_Mesh()
							addmodifier o myMod
							)
						modif = getVertSelection o o.modifiers[1] -- required a Edit_mesh modifier
						)
					str = filterstring o.name " :"
					vert_offset = tvert_offset = weight_offset = bonelimit = bound_offset = 0
					bone_map = #()
					for i = 1 to str.count do (
						case str[i] of (
							"vert": (
								vert_offset = execute str[(i+1)]
								)
							"tvert": (
								tvert_offset = execute str[(i+1)]
								)
							"weights": (
								weight_offset = execute str[(i+1)]
								)
							"bonelimit": (
								bonelimit = execute str[(i+1)]
								)
							"header": (
								bound_offset = execute str[(i+1)]
								)
							"bonemap": (
								bone_map = execute str[(i+1)]
								)
							)
						)
					if vert_offset!=undefined do (
						if updateVerts == true do (
							print "Vertices"
							fseek f vert_offset #seek_set
							if onlySelection == true then (
								for v = 1 to o.numverts do (
									if modif[v] == true then (
										vert = getVert o v
										writeBEfloat f (vert.x*mscale)
										writeBEfloat f -(vert.z*mscale)
										writeBEfloat f (vert.y*mscale)
										fseek f 0x0C #seek_cur
										)
									else (
										fseek f 0x18 #seek_cur
										)
									fseek f 0x04 #seek_cur
									)
								)
							else (
								for v = 1 to o.numverts do (
									vert = getVert o v
									writeBEfloat f (vert.x*mscale)
									writeBEfloat f -(vert.z*mscale)
									writeBEfloat f (vert.y*mscale)
									fseek f 0x10 #seek_cur
									)
								)
							)
						if updateNorms == true do (
							print "Normals"
							fseek f vert_offset #seek_set
							norms = getNormals(o)
							if onlySelection == true then (
								for v = 1 to o.numverts do (
									if modif[v] == true then (
										norm = norms[v]
										fseek f 0x0C #seek_cur
										writeBEfloat f -norm.x
										writeBEfloat f norm.z
										writeBEfloat f -norm.y
										)
									else (
										fseek f 0x18 #seek_cur
										)
									fseek f 0x04 #seek_cur
									)
								)
							else (
								for v = 1 to o.numverts do (
									norm = norms[v]
									fseek f 0x0C #seek_cur
									writeBEfloat f -norm.x
									writeBEfloat f norm.z
									writeBEfloat f -norm.y
									fseek f 0x04 #seek_cur
									)
								)
							)
						)
					if updateTverts == true do (
						Print "Texture Vertices"
						fseek f tvert_offset #seek_set
						if onlySelection == true then (
							for v = 1 to o.numtverts do (
								if modif[v] == true then (
									tvert = getTVert o v
									writeBEfloat f (tvert[1])
									writeBEfloat f (-tvert[2]+1)
									)
								else (
									fseek f 0x08 #seek_cur
									)
								)
							)
						else (
							for v = 1 to o.numtverts do (
								tvert = getTVert o v
								writeBEfloat f (tvert[1])
								writeBEfloat f (-tvert[2]+1)
								)
							)
						)
					if updateWeights == true and weight_offset!=undefined do (
						Print "Weights"
						boneArray = #()
						fseek f 0x20 #seek_set
						skel_count = readBElong f
						fseek f 0x28 #seek_set
						fseek f (readBElong f + 0x08) #seek_set
						for i = 1 to skel_count do (
							getpos = ftell f
							append boneArray (readstring f)
							fseek f (getpos + 0x50) #seek_set
							)
						mod_index = findModifier o Skin
						vertWeights = #()
						vertIndexWeights = #()
						if mod_index!=0 do (
							skinMod = o.modifiers[mod_index]
							select o
							max modify mode
							modPanel.setCurrentObject skinMod
							modPanel.setCurrentObject skinMod
							bones_total_count = skinops.getnumberbones skinMod
							for i = 1 to (getNumverts o) do ( -- loop through all bones affecting this vertex
								bw=#()
								bi=#()
								vertex_bone_count = skinOps.GetVertexWeightCount skinMod i
								if vertex_bone_count!=0 then (
									for bn = 1 to vertex_bone_count do (
										weight = skinops.getvertexweight skinMod i bn
										vertex_bone_id = finditem boneArray (skinOps.GetBoneName skinMod (skinOps.GetVertexWeightBoneID  skinMod i bn) 0)
										if findItem bone_map vertex_bone_id == 0 and vertex_bone_id!=0 do (
											append bone_map vertex_bone_id
											)
										vertex_bone_id = findItem bone_map vertex_bone_id
										if vertex_bone_id == 0 then (
											vertex_bone_id = 255
											)
										else (
											vertex_bone_id -= 1
											)
										append bw weight
										append bi vertex_bone_id
										)
									if bw.count < bonelimit do (
										for v = 1 to (bonelimit-bw.count) do (
											append bw 0.0
											append bi 255
											)
										)
									append vertWeights bw
									append vertIndexWeights bi
									)
								else ( --wont work
										append vertWeights #(1.0)
										append vertIndexWeights #(1)
									)
								)
							fseek f (bound_offset+0x08) #seek_set
							writeBElong f bone_map.count
							for v = 1 to 20 do (
								if v <= bone_map.count then (
									writeBElong f bone_map[v]
									)
								else (
									writebyte f 0xFF #unsigned
									writebyte f 0xFF #unsigned
									writebyte f 0xFF #unsigned
									writebyte f 0xFF #unsigned
									)
								)
							fseek f weight_offset #seek_set
							if onlySelection == true then (
								for v = 1 to o.numverts do (
									if modif[v] == true then (
										for v = 1 to o.numverts do (
											for x = 1 to bonelimit do (
												writelong f vertIndexWeights[v][x] #unsigned
												writeBEfloat f vertWeights[v][x]
												)
											)
										)
									else (
										fseek f (0x08 * bonelimit) #seek_cur
										)
									)
								)
							else (
								for v = 1 to o.numverts do (
									for x = 1 to bonelimit do (
										writelong f vertIndexWeights[v][x] #unsigned
										writeBEfloat f vertWeights[v][x]
										)
									)
								)
							)
						)
					if bound_offset!=undefined and updateBound == true do (
						fseek f (bound_offset+0xA4) #seek_set
						center = o.center*mscale
						dis = distance [0,0,0] center
						writefloat f center.x
						writefloat f -center.z
						writefloat f center.y
						writefloat f dis
						)
					fflush f
					if myMod!=undefined do (
						deleteModifier o myMod
						)
					)
				fclose f
				messagebox "DONE!!!!"
				)
			else (
				print "aborted"
				)
			boneArray=#() -- wipe out the bones
			)
		catch (
			messagebox "I'm Sorry An Error Occured :("
			)
		)
	on btn4 pressed do (
		try (
			if (
				writeTecPac (
					getFilenamePath (
						(
							GetOpenFileName \
							caption:"Select a File" \
							types: "All files (*.*)|*.*|"
							) \
						as string
						)
					)
				) \
			do (messagebox "Done!")
			)
		catch (
			messagebox "I'm Sorry An Error Occured :("
			)
		)
	on btn5 pressed do (
		try (
			if (
				writePach (
					getFilenamePath (
						(
							GetOpenFileName \
							caption:"Select a File" \
							types: "All files (*.*)|*.*|"
							) \
						as string
						)
					)
				) \
			do (messagebox "Done!")
			)
		catch (
			messagebox "I'm Sorry An Error Occured :("
			)
		)
	on btn5b pressed do (
		extractPach (
			GetOpenFileName \
				caption:"Select a File" \
				types: "Pach files (*.pac)|*.pac|All files (*.*)|*.*|"
			)
		)
	on btn4b pressed do (
		if (
			readTecPack (
				GetOpenFileName \
					caption:"Select a File" \
					types: "Pach files (*.tex)|*.tex|All files (*.*)|*.*|"
				)
			) \
		do (messagebox "Done!")
		)
	);createdialog RRXX_TOOL style:#(#style_titlebar, #style_resizing, #style_sysmenu)