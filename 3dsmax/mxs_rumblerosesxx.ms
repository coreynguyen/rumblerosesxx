-- MaxScript:    Imports Mesh From Rumble Roses XX
-- Written by:   Corey Nguyen
237-- Release Date: January 1, 2024

gc()
clearlistener()

try(DestroyDialog rrxx_util)catch(rrxx_util)
rollout rrxx_util "RRXX Utility 0.1" (
	
	group "Import" (
		button btn2 "Import" width:120 height:25
		spinner spn1 "Scale" type:#float range:[-10000000.0, 10000000.0, 3.93701]
		checkbox chk0 "Clear Scene" checked:true
		checkbox chk2 "Skeleton" checked:true enabled:false
		checkbox chk1 "Geometry" checked:true
		checkbox chk2B "Normals" checked:false
		checkbox chk3 "Skinning" checked:false
		checkbox chk3B "Colours" checked:false
		)
	group "Export" (
		button btn3 "Export" width:120 height:25
		button btn3C "Rewrite POF0" width:120 height:25
		)
	group "Packing" (
		button btn4 "Create tex File"
		button btn5 "Create pac File" enabled:false
		checkbox chkUseDos "OS for writes" checked:true toolTip:"Try to use DOS for processing large files"
		)
	group "UnPacking" (
		button btn4b "Unpack tex File"
		button btn5b "Unpack pac File" enabled:false
		)
	group "Material Copier" (
		pickbutton btn_pickSource     "Pick Source Object"  width:100 autoDisplay:true 
		spinner   spn_matIndex       "MatID:" type:#integer range:[1,999,1] fieldwidth:50
		button    btn_copyMaterial   "Copy Sub-material" width:100 
		button    btn_override       "Override Materials" width:100
		)
	group "About" (
		label lb3 "Written By:" align:#left
		label lb4 "    mariokart64n" align:#left
		hyperLink lb5 "    mariokart64n@gmail.com" address:"mailto:mariokart64n@gmail.com"
		label lb6 "Donate:" align:#left across:2
		hyperLink lb7 "    Paypal" address:"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=coreynguyen%40gmail%2ecom&item_name=maxscript%20work&no_shipping=0&no_note=1&tax=0&currency_code=CAD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8"
		)
	label lb3b "Release:" align:#left across:2
	label lb3c "January 1, 2025" align:#right
	
	-- Internal variables for Material Copier
	local sourceObj    = undefined
	local copiedSubMat = undefined
	
	local last_path = ""
	local caShaderParams = attributes ShaderMaterialAttributes (
		-- Declare parameters, linking via ui: to controls in the rollout
		local rrxx_shaders = #(
			"", "yBumpMap", "yBumpMapSS", "yDefault", "yReflect", "ySilhouette", "yUVScroll", "yWater"
			)
		parameters main rollout:params (
			-- Basic Properties
			unk14         type:#integer default:1    ui:spUnk14
			type  type:#index  default:1 ui:etName
			unk15         type:#integer default:4    ui:spUnk15
			unk16         type:#integer default:3    ui:spUnk16
			scale         type:#float   default:1.0  ui:spScale
			
			-- Diffuse Properties
			g_f4MatDifCol  type:#color default:(color 200 200 200) ui:cpDiffuseColor
			g_f4MatAmbCol  type:#color default:white ui:cpAmbientColor
			g_texDiffuse type:#texturemap ui:mbDiffuse
			texDiffuse type:#texturemap ui:mbDiffuse2
			g_bDiffTangent   type:#boolean default:false ui:cbUseTangent
			texNormal type:#texturemap ui:mbNormal
			
			
			-- Reflection Properties
			g_bReflectAdd type:#boolean default:false ui:cbReflectAdd
			g_bUseRefCube type:#boolean default:false ui:cbUseRefCube
			g_fReflectAlpha     type:#float default:0.5    ui:spReflectAlpha
			g_bUseRefRegMap   type:#boolean default:false ui:cbUseRefRegMap
			texSphRefction type:#texturemap ui:mbSphReflection
			texCubeRefction type:#texturemap ui:mbCubeReflection
			texRefctionReg type:#texturemap ui:mbRefRegMap
			texShimmer type:#texturemap ui:mbShimmerMap
			
			-- Specular Properties
			g_f4SpecularCol  type:#color default:white ui:cpSpecularColor
			g_fSpecularLev  type:#float default:1.0   ui:spSpecularLevel
			g_iSpecularPow  type:#integer default:16  ui:spSpecularPower
			texSpecularMap type:#texturemap ui:mbSpecularMap
			
			-- Wrinkles and Bruises
			g_bDrawWrinkle   type:#boolean default:false ui:cbDrawWrinkles
			g_fWrinkleBlend   type:#float default:0.0    ui:spWrinkleBlend
			g_f4BruiseCol    type:#color default:yellow ui:cpBruiseColor
			g_fBruiseLev    type:#float default:0.0    ui:spBruiseLevel
			g_iBruiseParts    type:#integer default:0     ui:spBruiseParts
			g_iWrinkleParts   type:#integer default:0     ui:spWrinkleParts
			texWrinkleMap type:#texturemap ui:mbWrinkleMap
			g_f2WrinkleRegUx    type:#float default:1.0    ui:spWrinkleRegUx
			g_f2WrinkleRegVx    type:#float default:1.0    ui:spWrinkleRegVx
			g_f2WrinkleRegUy    type:#float default:1.0    ui:spWrinkleRegUy
			g_f2WrinkleRegVy    type:#float default:1.0    ui:spWrinkleRegVy
			
			-- Glow & HDR Properties
			g_bUseGlow        type:#boolean default:false ui:cbUseGlow
			g_fHDRAlpha   type:#float default:1.0    ui:spHDRIntensity
			
			-- UV Scrolling
			g_fScrollU        type:#float default:0.0    ui:spScrollU
			g_fScrollV        type:#float default:0.0    ui:spScrollV
			g_fScrollU2       type:#float default:0.0    ui:spScrollU2
			g_fScrollV2       type:#float default:0.0    ui:spScrollV2
			g_fScrollU3       type:#float default:0.0    ui:spScrollU3
			g_fScrollV3       type:#float default:0.0    ui:spScrollV3
			g_fScrollU4       type:#float default:0.0    ui:spScrollU4
			g_fScrollV4       type:#float default:0.0    ui:spScrollV4
			texUVScroll type:#texturemap ui:mbUVScroll
			texUVScroll2 type:#texturemap ui:mbUVScroll2
			texUVScroll3 type:#texturemap ui:mbUVScroll3
			texUVScroll4 type:#texturemap ui:mbUVScroll4
			
			-- Tiling
			g_fTileCountU     type:#float default:1.0    ui:spTileCountU
			g_fTileCountV     type:#float default:1.0    ui:spTileCountV
			g_f4TileEffValX    type:#float default:0.0    ui:spTileEffValX
			g_f4TileEffValY    type:#float default:0.0    ui:spTileEffValY
			g_f4TileEffValZ    type:#float default:0.0    ui:spTileEffValZ
			g_f4TileEffValW    type:#float default:0.0    ui:spTileEffValW
			g_fTileEffSw  type:#float default:0.0    ui:spTileEffSwitch
			texTilingMap type:#texturemap ui:mbTilingMap
			
			-- Additional Effects
			g_fAmbOccDif      type:#float default:1.0    ui:spAmbOccDif
			g_fAmbOccLev      type:#float default:1.0    ui:spAmbOccLev
			texOcclusion type:#texturemap ui:mbOcclusion
			g_fSweatLev       type:#float default:0.0    ui:spSweatLev
			g_fSweatSPA       type:#float default:0.0    ui:spSweatSPA
			g_fWaveSpeed      type:#float default:1.0    ui:spWaveSpeed
			g_fvLightLimitX    type:#float default:1.0    ui:spLightLimitX
			g_fvLightLimitY    type:#float default:1.0    ui:spLightLimitY
			g_fvLightLimitZ    type:#float default:1.0    ui:spLightLimitZ
			g_fvLightLimitW    type:#float default:1.0    ui:spLightLimitW
			g_fNoizeSpeed      type:#float default:1.0    ui:spNoizeSpeed
			texNoizeMap type:#texturemap ui:mbNoizeMap
			
			-- Experimental Fairy Effects
			g_f4FairyX         type:#float default:0.0    ui:spFairyX
			g_f4FairyY         type:#float default:0.0    ui:spFairyY
			g_f4FairyZ         type:#float default:0.0    ui:spFairyZ
			g_f4FairyW         type:#float default:0.0    ui:spFairyW
			g_f4FairyColorC    type:#color default:(color 255 0 255) ui:cpFairyColorC
			g_f4FairyColorO    type:#color default:(color 0 255 255) ui:cpFairyColorO
			g_f4FairyLvX       type:#float default:0.0    ui:spFairyLvX
			g_f4FairyLvY       type:#float default:0.0    ui:spFairyLvY
			g_f4FairyLvZ       type:#float default:0.0    ui:spFairyLvZ
			g_f4FairyLvW       type:#float default:0.0    ui:spFairyLvW
			g_f4ScaleX       type:#float default:0.0    ui:spScaleX
			g_f4ScaleY       type:#float default:0.0    ui:spScaleY
			g_f4ScaleZ       type:#float default:0.0    ui:spScaleZ
			g_f4ScaleW       type:#float default:0.0    ui:spScaleW
			
			-- Enable Flags
			
			enable1   type:#integer default:0xFFFF     ui:spEnable1
			enable2   type:#integer default:0xFFFF     ui:spEnable2
			enable3   type:#integer default:0xFFFF     ui:spEnable3
			enable4   type:#integer default:0xFFFF     ui:spEnable4
			)
		
		-- 2) Define the rollout named "params"
		rollout params "Shader Material Properties" (
			
			/*------------------------------------
			Basic Properties
			------------------------------------*/
			group "Shader Properties" (
				label lbl_etName "Shader Name:" align:#left across:2
				dropdownlist etName "" text:"yBumpMap" width:200 align:#right items:rrxx_shaders
				spinner spUnk14 "Priority (unk14):" range:[0,999,1] type:#integer fieldwidth:60 across:2
				spinner spUnk15 "Unknown (unk15):" range:[0,999,4] type:#integer fieldwidth:60
				spinner spUnk16 "Flag (unk16):" range:[0,8,3] type:#integer fieldwidth:60
				)
			
			/*------------------------------------
			Diffuse Properties
			------------------------------------*/
			group "Basic Properties" (
				colorPicker cpAmbientColor "Ambient Color:" alpha:true color:(color 200 200 200) width:280                      -- g_f4MatAmbCol
				colorPicker cpDiffuseColor "Diffuse Color:" alpha:true color:(color 200 200 200) width:280                      -- g_f4MatDifCol
				
				mapButton mbDiffuse "Diffuse Map:" width:280 autoDisplay:true                                                   -- g_texDiffuse
				mapButton mbDiffuse2 "Secondary Diffuse Map:" width:280 autoDisplay:true                                        -- texDiffuse
				
				colorPicker cpSpecularColor "Specular Color:" alpha:true color:white width:280                                  -- g_f4SpecularCol
				spinner spSpecularLevel "Specular Level:" range:[0.0,10.0,1.0] type:#float fieldwidth:180                       -- g_fSpecularLev
				spinner spSpecularPower "Specular Power:" range:[1,256,16] type:#integer fieldwidth:180                         -- g_iSpecularPow
				mapButton mbSpecularMap "Specular Map:" width:280 autoDisplay:true                                              -- texSpecularMap
				
				-- Normal
				label lblNorm "Normal:" align:#left
				checkbox cbUseTangent      "Use Tangent Space (g_bDiffTangent)"   checked:true                                  -- g_bDiffTangent
				spinner spScale "Scale (g_f4Scale):" range:[0.0,10.0,1.0] type:#float fieldwidth:40                             -- g_fSL_Scale
				mapButton mbNormal        "Normal Map:"           width:140 autoDisplay:true                                    -- texNormal
				
				-- Ambient Occlusion
				label lblAmbOcc "Ambient Occlusion:" align:#left
				spinner spAmbOccDif "Ambient Occ Diff:" range:[0.0,10.0,1.0] type:#float fieldwidth:40 align:#center across:2   -- g_fAmbOccDif
				spinner spAmbOccLev "Ambient Occ Level:" range:[0.0,10.0,1.0] type:#float fieldwidth:40 align:#right            -- g_fAmbOccLev
				mapButton mbOcclusion "Occlusion Map:" width:280 autoDisplay:true                                               -- texOcclusion
				)
			
			/*------------------------------------
			Reflection Properties
			------------------------------------*/
			group "Reflection Properties" (
				checkbox cbReflectAdd      "Additional Reflections (g_bReflectAdd)"                                             -- g_bReflectAdd
				spinner spReflectAlpha "Reflection Alpha:" range:[0.0,1.0,0.5] type:#float fieldwidth:40 align:#right           -- g_fReflectAlpha
				
				mapButton mbSphReflection "Spherical Reflection Map:" width:280 autoDisplay:true                                -- texSphRefction
				
				checkbox cbUseRefCube "Use Cube Map Reflection" checked:false align:#left across:2                              -- g_bUseRefCube
				mapButton mbCubeReflection "Cube Reflection Map:"  width:140 autoDisplay:true                                   -- texCubeRefction
				
				checkbox cbUseRefRegMap "Use Reflection Region Map" checked:false width:280                                     -- g_bUseRefRegMap
				mapButton mbRefRegMap "Reflection Region Map:" width:280 autoDisplay:true                                       -- texRefctionReg
				mapButton mbShimmerMap "Shimmer Map:" width:280 autoDisplay:true                                       -- texShimmer
				)
			
			
			/*------------------------------------
			Wrinkles
			------------------------------------*/
			group "Wrinkles" (
				checkbox cbDrawWrinkles "Enable Wrinkles" checked:false width:280                                               -- g_bDrawWrinkle
				mapButton mbWrinkleMap "Wrinkle Map:" width:280 autoDisplay:true                                                -- texWrinkleMap
				label lblWrinkleU "Wrinkle Region U (g_f2WrinkleRegU):"                                                         -- g_f2WrinkleRegU
				spinner spWrinkleRegUx "U.X:" range:[-1e6,1e6,0.0] type:#float fieldwidth:60 across:2
				spinner spWrinkleRegUy "U.Y:" range:[-1e6,1e6,0.0] type:#float fieldwidth:60
				
				label lblWrinkleV "Wrinkle Region V (g_f2WrinkleRegV):"                                                         -- g_f2WrinkleRegV
				spinner spWrinkleRegVx "V.X:" range:[-1e6,1e6,0.0] type:#float fieldwidth:60 across:2
				spinner spWrinkleRegVy "V.Y:" range:[-1e6,1e6,0.0] type:#float fieldwidth:60
				spinner spWrinkleBlend "Wrinkle Blend:" range:[0.0,10.0,0.0] type:#float fieldwidth:180                         -- g_fWrinkleBlend
				spinner spWrinkleParts "Wrinkle Parts:" range:[0,100,0] type:#integer fieldwidth:180                            -- g_iWrinkleParts
				)
			
			/*------------------------------------
			Bruises
			------------------------------------*/
			group "Bruises" (
				colorPicker cpBruiseColor "Bruise Color:" alpha:true color:yellow width:280                                     -- g_f4BruiseCol
				spinner spBruiseLevel "Bruise Level:" range:[0.0,10.0,0.0] type:#float fieldwidth:180                           -- g_fBruiseLev
				spinner spBruiseParts "Bruise Parts:" range:[0,100,0] type:#integer fieldwidth:180                              -- g_iBruiseParts
				)
			
			/*------------------------------------
			Glow & HDR Properties
			------------------------------------*/
			group "Glow & HDR Properties" (
				checkbox cbUseGlow "Enable Glow" checked:false width:280                                                        -- g_bUseGlow
				spinner spHDRIntensity "HDR Intensity:" range:[0.0,10.0,1.0] type:#float fieldwidth:180                         -- g_fHDRAlpha
				)
			
			/*------------------------------------
			UV Scrolling & Tiling
			------------------------------------*/
			group "UV Scrolling & Tiling" (
				label lblUVScroll "UV Scrolling:" align:#left
				spinner spScrollU "Scroll U:" range:[-10.0,10.0,0.0] type:#float fieldwidth:80 across:2                         -- g_fScrollU
				spinner spScrollV "Scroll V:" range:[-10.0,10.0,0.0] type:#float fieldwidth:80                                  -- g_fScrollV
				spinner spScrollU2 "Scroll U2:" range:[-10.0,10.0,0.0] type:#float fieldwidth:80 across:2                       -- g_fScrollU2
				spinner spScrollV2 "Scroll V2:" range:[-10.0,10.0,0.0] type:#float fieldwidth:80                                -- g_fScrollV2
				spinner spScrollU3 "Scroll U3:" range:[-10.0,10.0,0.0] type:#float fieldwidth:80 across:2                       -- g_fScrollU3
				spinner spScrollV3 "Scroll V3:" range:[-10.0,10.0,0.0] type:#float fieldwidth:80                                -- g_fScrollV3
				spinner spScrollU4 "Scroll U4:" range:[-10.0,10.0,0.0] type:#float fieldwidth:80 across:2                       -- g_fScrollU4
				spinner spScrollV4 "Scroll V4:" range:[-10.0,10.0,0.0] type:#float fieldwidth:80                                -- g_fScrollV4
				mapButton mbUVScroll     "UV Scroll 1:" width:280 autoDisplay:true                                             -- texUVScroll
				mapButton mbUVScroll2     "UV Scroll 2:" width:280 autoDisplay:true                                             -- texUVScroll2
				mapButton mbUVScroll3     "UV Scroll 3:" width:280 autoDisplay:true                                             -- texUVScroll3
				mapButton mbUVScroll4     "UV Scroll 4:" width:280 autoDisplay:true                                             -- texUVScroll4
				spinner spTileCountU "Tile Count U:" range:[1.0,100.0,1.0] type:#float fieldwidth:80 across:2                   -- g_fTileCountU
				spinner spTileCountV "Tile Count V:" range:[1.0,100.0,1.0] type:#float fieldwidth:80                            -- g_fTileCountV
				
				spinner spTileEffValX "Tile Eff Val X:" range:[-10.0,10.0,0.0] type:#float fieldwidth:80 across:2				-- g_f4TileEffVal
				spinner spTileEffValY "Tile Eff Val Y:" range:[-10.0,10.0,0.0] type:#float fieldwidth:80
				spinner spTileEffValZ "Tile Eff Val Z:" range:[-10.0,10.0,0.0] type:#float fieldwidth:80 across:2
				spinner spTileEffValW "Tile Eff Val W:" range:[-10.0,10.0,0.0] type:#float fieldwidth:80
				spinner spTileEffSwitch "Tile Eff Switch:" range:[0.0,10.0,0.0] type:#float fieldwidth:100                      -- g_fTileEffSw
				
				mapButton mbTilingMap "Tiling Map:" width:280 autoDisplay:true                                                  -- texTilingMap
				)
			
			/*------------------------------------
			Additional Effects
			------------------------------------*/

			group "Sweat Effects" (
				-- Sweat Effects
				label lblSweat "Sweat Effects:" align:#left
				spinner spSweatLev "Sweat Level:" range:[0.0,10.0,0.0] type:#float fieldwidth:40 align:#center across:2     -- g_fSweatLev
				spinner spSweatSPA "Sweat SPA:" range:[0.0,10.0,0.0] type:#float fieldwidth:40 align:#right                 -- g_fSweatSPA
				)
				
			group "Light Effects" (
				
				-- Light Limit
				label lblLightLimit "Light Limit:" align:#left                                                              -- g_fvLightLimit
				spinner spLightLimitX "Light X:" range:[-10.0,10.0,1.0] type:#float width:80 across:2
				spinner spLightLimitY "Light Y:" range:[-10.0,10.0,1.0] type:#float width:80
				spinner spLightLimitZ "Light Z:" range:[-10.0,10.0,1.0] type:#float width:80 across:2
				spinner spLightLimitW "Light W:" range:[-10.0,10.0,1.0] type:#float width:80
				
				-- Experimental Fairy Effects
				label lblFairy "Fairy Effects (Experimental):" align:#left                                                  -- g_f4Fairy
				spinner spFairyX "Fairy X:" range:[-10.0,10.0,0.0] type:#float width:80 across:2
				spinner spFairyY "Fairy Y:" range:[-10.0,10.0,0.0] type:#float width:80
				spinner spFairyZ "Fairy Z:" range:[-10.0,10.0,0.0] type:#float width:80 across:2
				spinner spFairyW "Fairy W:" range:[-10.0,10.0,0.0] type:#float width:80
				
				colorPicker cpFairyColorC "Fairy Color C:" alpha:true color:(color 255 0 255) width:280                     -- g_f4FairyColorC
				colorPicker cpFairyColorO "Fairy Color O:" alpha:true color:(color 0 255 255) width:280                     -- g_f4FairyColorO
				
				label lblFairyLv "Fairy Level:" align:#left                                                                 -- g_f4FairyLv
				spinner spFairyLvX "Fairy Lv X:" range:[-10.0,10.0,0.0] type:#float width:80 across:2
				spinner spFairyLvY "Fairy Lv Y:" range:[-10.0,10.0,0.0] type:#float width:80
				spinner spFairyLvZ "Fairy Lv Z:" range:[-10.0,10.0,0.0] type:#float width:80 across:2
				spinner spFairyLvW "Fairy Lv W:" range:[-10.0,10.0,0.0] type:#float width:80
				
				)
			group "Additional Effects" (
				-- Wave Speed
				spinner spWaveSpeed "Wave Speed:" range:[0.0,10.0,1.0] type:#float fieldwidth:100                           -- g_fWaveSpeed
				spinner spNoizeSpeed "Noise Speed:" range:[0.0,10.0,1.0] type:#float fieldwidth:100                         -- g_fNoizeSpeed
				mapButton mbNoizeMap "Noise Map:" width:280 autoDisplay:true                                                -- texNoizeMap
				)
			group "Transform" (
				
				label lblScale  "Scale (4D)"          align:#left                                                           -- g_f4Scale
				spinner spScaleX "X:" range:[-10.0,10.0,1.0] type:#float width:80 across:2
				spinner spScaleY "Y:" range:[-10.0,10.0,1.0] type:#float width:80
				spinner spScaleZ "Z:" range:[-10.0,10.0,1.0] type:#float width:80 across:2
				spinner spScaleW "W:" range:[-10.0,10.0,1.0] type:#float width:80
				
				
				)
			spinner spEnable1 "" type:#integer range:[0, 65535, 0] visible:false across:4
			spinner spEnable2 "" type:#integer range:[0, 65535, 0] visible:false
			spinner spEnable3 "" type:#integer range:[0, 65535, 0] visible:false
			spinner spEnable4 "" type:#integer range:[0, 65535, 0] visible:false
			
			/*------------------------------------
			Event Handlers for mapButton Controls
			------------------------------------*/
			
			
			-- Add more event handlers for other mapButton controls as needed
			)
		)

	fn attachShaderAttributesToMaterial theMat = (
		if (classof theMat == StandardMaterial) then (
			-- Initialize a flag to check if the attribute is already attached
			local alreadyAttached = false
			
			-- Iterate through all custom attributes attached to the material
			for i = 1 to custAttributes.count theMat do (
				local existingCA = custAttributes.get theMat i
				-- Check if the existing custom attribute matches "ShaderMaterialAttributes"
				if (existingCA != undefined and existingCA.name == "ShaderMaterialAttributes") then (
					alreadyAttached = true
					exit -- Exit the loop early since we found the attribute
					)
				)
			
			-- If the custom attribute is not already attached, add it
			if (not alreadyAttached) then (
				custAttributes.add theMat caShaderParams
				
				) else (print "Material already has ShaderMaterialAttributes.")
			) else (print "Please pass a StandardMaterial to attachShaderAttributesToMaterial().")
		)

	struct bytestream (
		fullpath = "",
		filename = "",
		name = "",
		path = "",
		type = "",
		size = 0,
		swapBytes = false,
		bstream = undefined,
		fn open file mode:"rb" = (
			local isOpened = false
			if file != undefined and file != "" do (
				bstream = try(fopen file mode)catch(undefined)
				if bstream != undefined then (
					fseek bstream 0 #seek_end
					size = ftell bstream
					fseek bstream 0 #seek_set
					fullpath = file
					filename = filenameFromPath file
					name = getFilenameFile filename
					path = getFilenamePath file
					type = getFilenameType filename
					isOpened = true
					) else (format "Error:\n\tFailed to Open {%}\n" file)
				)
			isOpened
			),
		fn close = (
			size = 0
			fullpath = filename = name = path = type = ""
			if bstream != undefined do (fclose bstream)
			),
		fn good = (bstream != undefined),
		fn setEndian endian = (if endian == #little then swapBytes = false else if endian == #big then swapBytes = true),
		fn isBigEndian = (swapBytes),
		fn isLittleEndian = (not swapBytes),
		fn littleEndian = (swapBytes = false),
		fn bigEndian = (swapBytes = true),
		fn seek offset seekdir:#seek_set = (fseek bstream offset seekdir),
		fn align byte_alignment position:undefined = (
			if position == undefined do (position = ftell bstream)
			fseek bstream (mod (byte_alignment-(mod position byte_alignment)) byte_alignment) #seek_cur
			((ftell bstream) - position)
			),
		fn write_padding byte_alignment position:undefined = (
			if position == undefined do (position = ftell bstream)
			local p = align byte_alignment position:position
			if p > 0 do (
				local i = 1
				for i = 1 to p do (writeByte bstream 0)
				)
			),
		fn tell = (ftell bstream),
		fn print_tell tell_name = (
			local u = #("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
			local l = #("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z")
			local b = 0, s = 1, p = (tell() as integer), n = bit.IntAsHex(p)
			for s = 1 to n.count do (if (b = findItem l n[s]) > 0 do (n[s] = u[b]))
			format "%: \t@ 0x% \t\tdec: %\n" tell_name (substring (n = "00000000" + n) (n.count - 7) (n.count + 6)) p
			),
		fn eos = (not (ftell bstream < size)),
		fn unsigned_to_signed &n nbits = (
			-- unsigned_to_signed 0x80 8 = -128
			if bit.get n nbits do (
				n = n - (pow 2 nbits)
				)
			),
		fn read_ubyte = (
			readbyte bstream #unsigned
			),
		fn read_byte = (
			readbyte bstream #signed
			),
		fn read_ushort = (
			local val = readshort bstream #unsigned
			if swapBytes do (val = bit.swapBytes val 1 2)
			val
			),
		fn read_short = (
			local val = read_ushort()
			unsigned_to_signed &val 16
			val
			),
		fn read_ulong = (
			local val = readlong bstream #unsigned
			if swapBytes do (val = bit.swapBytes (bit.swapBytes val 1 4) 2 3)
			val
			),
		fn read_long = (
			local val = read_ulong()
			unsigned_to_signed &val 32
			val
			),
		fn read_ulonglong = (
			local val = 0L
			if not swapBytes then (
				val += readlonglong bstream #unsigned
				)
			else (
				val += (
					((readbyte bstream #unsigned) * 0x0100000000000000) + \
					((readbyte bstream #unsigned) * 0x0001000000000000) + \
					((readbyte bstream #unsigned) * 0x0000010000000000) + \
					((readbyte bstream #unsigned) * 0x0000000100000000) + \
					((readbyte bstream #unsigned) * 0x0000000001000000) + \
					((readbyte bstream #unsigned) * 0x0000000000010000) + \
					((readbyte bstream #unsigned) * 0x0000000000000100) + \
					((readbyte bstream #unsigned) * 0x0000000000000001)
					)
				)
			val
			),
		fn read_longlong = (
			local val = 0L
			if not swapBytes then (
				val += readlonglong bstream #signed
				)
			else (
				val += (
					((readbyte bstream #unsigned) * 0x0100000000000000) + \
					((readbyte bstream #unsigned) * 0x0001000000000000) + \
					((readbyte bstream #unsigned) * 0x0000010000000000) + \
					((readbyte bstream #unsigned) * 0x0000000100000000) + \
					((readbyte bstream #unsigned) * 0x0000000001000000) + \
					((readbyte bstream #unsigned) * 0x0000000000010000) + \
					((readbyte bstream #unsigned) * 0x0000000000000100) + \
					((readbyte bstream #unsigned) * 0x0000000000000001)
					)
				unsigned_to_signed &val 64
				)
			val
			),
		fn read_half = (
			local inputAsInt = readshort bstream #unsigned
			if swapBytes do (inputAsInt = bit.swapBytes inputAsInt 1 2)
			local sign = (bit.and (bit.shift inputAsInt -15) 0x00000001)
			local exponent = (bit.shift (bit.and inputAsInt 0x7C00) -10) as integer + 112
			local fraction = (bit.and inputAsInt 0x03FF)
			bit.intasfloat (
				(bit.or (bit.or (bit.shift fraction 13) (bit.shift exponent 23)) (bit.shift sign 31))
				)
			),
		fn read_float = (
			if swapBytes then (
				bit.intAsFloat (bit.swapBytes (bit.swapBytes (readlong bstream #unsigned) 1 4) 2 3)
				)
			else (
				readfloat bstream
				)
			),
		fn read_double = (
			local i=1,ma=0,mb=0,mc=0,ex=0,bits=11,sign=0,expo=0,mant=0.0,bias=0
			if swapBytes then (
				mc = readshort bstream #unsigned
				mb = readshort bstream #unsigned
				ma = readshort bstream #unsigned
				ex = readshort bstream #unsigned
				)
			else (
				ex = bit.swapBytes (readshort bstream #unsigned) 1 2
				ma = bit.swapBytes (readshort bstream #unsigned) 1 2
				mb = bit.swapBytes (readshort bstream #unsigned) 1 2
				mc = bit.swapBytes (readshort bstream #unsigned) 1 2
				)
			sign = if bit.get ex 16 then 1 else 0;bias = (pow 2 (bits - 1)) - 1
			for i = 1 to bits do (expo = bit.set expo (bits-(i-1)) (bit.get ex (16-i)))
			for i = 1 to 4 do (mant+= (if bit.get ex (4-(i-1)) then 1 else 0) * (pow 2 -i))
			for i = 1 to 16 do (mant+= (if bit.get ma (16-(i-1)) then 1 else 0) * (pow 2 -(i+4)))
			for i = 1 to 16 do (mant+= (if bit.get mb (16-(i-1)) then 1 else 0) * (pow 2 -(i+20)))
			for i = 1 to 16 do (mant+= (if bit.get mc (16-(i-1)) then 1 else 0) * (pow 2 -(i+36)))
			(pow (-1) sign) * (1 + mant) * (pow 2 (expo - bias))
			),
		fn read_string length:-1 = (
			local i = 1, s = "", b = 1
			if length == -1 then (s = readString bstream)
			else (
				for i = 1 to length do (
					b = readbyte bstream #unsigned
					if b > 0 then (
						s += bit.IntAsChar b
						)
					else (
						fseek bstream (length - i) #seek_cur
						exit
						)
					)
				)
			s
			),
		fn read_wstring length:0 = (
			local i = 1, s = "", b = 1
			if length == 0 then (
				do (
					b = read_ushort()
					if b > 0 do (
						s += bit.IntAsChar b
						)
					) while i > 0
				)
			else (
				for i = 1 to (length / 2) do (
					b = read_ushort()
					if b > 0 then (
						s += bit.IntAsChar b
						)
					else (
						fseek bstream (length - (i * 2)) #seek_cur
						exit
						)
					)
				)
			s
			),
		fn write_string str length:0 = (
			local i = 1
			if length == 0 then (
				writestring bstream str
				)
			else (
				for i = 1 to length do (
					if i <= str.count and i != length then (
						writebyte bstream (bit.CharAsInt str[i]) #unsigned
						)
					else (
						writebyte bstream 0
						)
					)
				)
			),
		fn write_ubyte val = (
			writebyte bstream val #unsigned
			),
		fn write_byte val = (
			writebyte bstream val #signed
			),
		fn write_ushort val = (
			if swapBytes do (val = bit.swapBytes val 1 2)
			writeshort bstream val #unsigned
			),
		fn write_short val = (
			if swapBytes do (val = bit.swapBytes val 1 2)
			writeshort bstream val #signed
			),
		fn write_ulong val = (
			if swapBytes do (val = bit.swapBytes (bit.swapBytes val 1 4) 2 3)
			writelong bstream val #unsigned
			),
		fn write_long val = (
			if swapBytes do (val = bit.swapBytes (bit.swapBytes val 1 4) 2 3)
			writelong bstream val #signed
			),
		fn write_ulonglong num = (
			local val = 0L + num
			if not swapBytes then (
				writelonglong bstream val #unsigned
				)
			else (
				writebyte bstream (bit.shift (bit.and val 0xFF00000000000000L) -0x38) #unsigned
				writebyte bstream (bit.shift (bit.and val 0x00FF000000000000L) -0x30) #unsigned
				writebyte bstream (bit.shift (bit.and val 0x0000FF0000000000L) -0x28) #unsigned
				writebyte bstream (bit.shift (bit.and val 0x000000FF00000000L) -0x20) #unsigned
				writebyte bstream (bit.shift (bit.and val 0x00000000FF000000L) -0x18) #unsigned
				writebyte bstream (bit.shift (bit.and val 0x0000000000FF0000L) -0x10) #unsigned
				writebyte bstream (bit.shift (bit.and val 0x000000000000FF00L) -0x08) #unsigned
				writebyte bstream (            bit.and val 0x00000000000000FFL          ) #unsigned
				)
			),
		fn write_longlong num = (
			local val = 0L + num
			if not swapBytes then (
				writelonglong bstream val #signed
				)
			else (
				writebyte bstream (bit.shift (bit.and val 0xFF00000000000000L) -0x38) #unsigned
				writebyte bstream (bit.shift (bit.and val 0x00FF000000000000L) -0x30) #unsigned
				writebyte bstream (bit.shift (bit.and val 0x0000FF0000000000L) -0x28) #unsigned
				writebyte bstream (bit.shift (bit.and val 0x000000FF00000000L) -0x20) #unsigned
				writebyte bstream (bit.shift (bit.and val 0x00000000FF000000L) -0x18) #unsigned
				writebyte bstream (bit.shift (bit.and val 0x0000000000FF0000L) -0x10) #unsigned
				writebyte bstream (bit.shift (bit.and val 0x000000000000FF00L) -0x08) #unsigned
				writebyte bstream (            bit.and val 0x00000000000000FFL          ) #unsigned
				)
			),
		fn write_float val = (
			if swapBytes then (
				writelong bstream (bit.swapBytes (bit.swapBytes (bit.floatAsInt val) 1 4) 2 3) #unsigned
				)
			else (
				writefloat bstream val
				)
			),
		fn write_half val = (
			-- "https://galfar.vevb.net/wp/2011/16bit-half-float-in-pascaldelphi/"
			local Sign = 0
			local exponent=0
			local Mantissa=0
			local Result = 0
			local Src = bit.floatAsInt (val as float)
			-- Extract sign, exponentonent, and mantissa from Single number
			Sign = bit.shift Src -31
			exponent = (bit.shift (bit.and Src 0x7F800000) -23) - 127 + 15
			Mantissa = bit.and Src 0x007FFFFF
			if exponent >= 0 and exponent <= 30 then (
				-- Simple case - round the significand and combine it with the sign and exponentonent
				Result = bit.or (bit.shift Sign 15) (bit.or (bit.shift exponent 10) (bit.shift (Mantissa + 0x00001000) -13))
				)
			else (
				if Src == 0 then (
					-- Input float is zero - return zero
					Result = 0
					)
				else (
					-- Difficult case - lengthy conversion
					if exponent <= 0 then (
						if exponent <= -10 then (         
							-- Input float's value is less than HalfMin, return zero
							Result = 0
							)
						else (
							-- Float is a normalized Single whose magnitude is less than HalfNormMin.  
							-- We convert it to denormalized half.
							Mantissa = bit.shift (bit.or Mantissa 0x00800000) -(1 - exponent)
							-- Round to nearest
							if (bit.or Mantissa 0x00001000) >= 0 then
							Mantissa = Mantissa + 0x00002000
							-- Assemble Sign and Mantissa (exponent is zero to get denormalized number)
							Result = bit.or (bit.shift Sign 15) (bit.shift Mantissa -13)
							)
						)
					else (
						if exponent = 255 - 127 + 15 then (
							if Mantissa = 0 then (
								-- Input float is infinity, create infinity half with original sign
								Result = (bit.shift Sign 15) or 0x7C00
								)
							else (
								-- Input float is NaN, create half NaN with original sign and mantissa
								Result = bit.or (bit.shift Sign 15) (bit.or 0x7C00 (bit.shift Mantissa -13))
								)
							)
						else (
							-- exponent is > 0 so input float is normalized Single
							-- Round to nearest
							if (bit.and Mantissa 0x00001000) >= 0 then (
								Mantissa = Mantissa + 0x00002000
								if (bit.and Mantissa 0x00800000) >= 0 then (
									Mantissa = 0
									exponent = exponent + 1
									)
								)
							if exponent >= 30 then (
								-- exponentonent overflow - return infinity half
								Result = (bit.shift Sign 15) or 0x7C00
								)
							else (
								-- Assemble normalized half
								Result = bit.or (bit.shift Sign 15) (bit.or (bit.shift exponent 10) (bit.shift Mantissa -13))
								)
							)
						)
					)
				)
			if swapBytes do (result = bit.swapBytes result 1 2)
			writeshort bstream result #unsigned
			)
		)

	struct byteArray (
		size = 0,
		data = #(),
		fn readFromStream &f fsize:0 = (
			if f != undefined then (
				local pos = ftell f
				if fsize == 0 do (
					fseek f 0 #seek_end
					fsize = (ftell f) - pos
					fseek f pos #seek_set
					)
				size = fsize
				local count = (size / 4) as integer
				local leftover = (mod size 4) as integer
				if (count + leftover) > 0 do (
					data[count + leftover] = 1
					local i = 1
					for i = 1 to count do (data[i] = readLong f)
					for i = (1 + count) to (count + leftover) do (data[i] = readByte f)
					)
				) else (format "stream is invalid\n")
			),
		fn writeToStream &s = (
			local count = (size / 4) as integer
			local leftover = (mod size 4) as integer
			if (count + leftover) > 0 do (
				local i = 1
				for i = 1 to count do (writeLong s data[i])
				for i = (1 + count) to (count + leftover) do (writeByte s data[i])
				)
			),
		fn read file = (
			local f = undefined
			if (f = try(fopen file "rbS")catch(undefined)) != undefined then (
				data = #()
				readFromStream f fsize:(getFileSize file)
				fclose f
				) else (format "Error:\tFailed to Load File\n")
			),
		fn write file = (
			local s = undefined
			if size >= data.count and data.count > 0 and (s = try(fopen file "wbS")catch(undefined)) != undefined then (
				writeToStream(&s)
				fclose s
				) else (format "Error:\tFailed to Save File\n")
			)
		)
	
	struct PointerOffsets_t ( -- 8 bytes + n bytes
		/*uint32*/ fileid    = 0x504F4630,
		/*uint32*/ count     = 0,
		/*uint8[]*/ encoding = #(),
		
		/*uint8[]*/ offsets  = #(),
		
		fn encode integerArray = (
			/*
				encode integerArray:
				
				Encodes an array of 32-bit integers into a variable-length sequence of bytes.
				Each integer is encoded into 1, 2, or 4 bytes based on its size:
				  - 1 byte: values <= 0xFC
				  - 2 bytes: values <= 0xFFFC
				  - 4 bytes: all other values
				The encoding uses the top 2 bits of the first byte to indicate the length:
				  - 0x40: 1-byte case
				  - 0x80: 2-byte case
				  - 0xC0: 4-byte case
				For multi-byte cases, big-endian byte order is used.
				Returns a single array of encoded bytes.
			*/
			
			local out = #()  -- Array to hold encoded bytes
			for sp in integerArray do (
				if sp <= 0xFC then (
					-- 1-byte case: sp is small enough to fit in a single byte
					local val = bit.shift sp -2   -- Right-shift by 2 to reduce size
					val = bit.or val 0x40        -- Set top bits to '01' (0x40)
					append out val
					)
				else if sp <= 0xFFFC then (
					-- 2-byte case: sp is small enough for 2 bytes
					local val = bit.or (bit.shift sp -2) 0x8000  -- Right-shift and set top bits to '10' (0x8000)
					local hi = bit.shift val -8                 -- Extract high byte
					local lo = bit.and val 0xFF                 -- Extract low byte
					append out hi                          -- Append high byte first (big-endian)
					append out lo                          -- Append low byte
					)
				else (
					-- 4-byte case: sp requires full 32-bit encoding
					local val = bit.or (bit.shift sp -2) 0xC0000000  -- Right-shift and set top bits to '11' (0xC0000000)
					local b1 = bit.shift val -24                     -- Extract 1st byte
					local b2 = bit.and (bit.shift val -16) 0xFF      -- Extract 2nd byte
					local b3 = bit.and (bit.shift val -8)  0xFF      -- Extract 3rd byte
					local b4 = bit.and val 0xFF                      -- Extract 4th byte
					append out b1
					append out b2
					append out b3
					append out b4
					)
				)
			out
			),
		
		fn decode byteArray = (
			/*
				decode byteArray:
				
				Decodes an array of bytes encoded using the variable-length scheme back
				into the original array of integers. It reads 1, 2, or 4 bytes depending
				on the top 2 bits of the first byte:
				  - 0x40: 1-byte case
				  - 0x80: 2-byte case
				  - 0xC0: 4-byte case
				For multi-byte cases, big-endian byte order is used to reconstruct the integer.
				Returns the decoded array of integers.
			*/
			
			local results = #()  -- Array to hold decoded integers
			local i = 1          -- Index into the byte array
			
			while i <= byteArray.count do (
				local firstByte = byteArray[i]
				i += 1
				
				local top2 = bit.and firstByte 0xC0  -- Extract top 2 bits to determine case
				local sp = 0                        -- Decoded integer
				
				if top2 == 0x40 then (
					-- 1-byte case: top bits = '01'
					local val = bit.and firstByte 0x3F  -- Extract lower 6 bits
					append results (bit.shift val 2)               -- Left-shift to restore original
					)
				else if top2 == 0x80 then (
					-- 2-byte case: top bits = '10'
					if i > byteArray.count do exit  -- Ensure enough bytes remain
					local secondByte = byteArray[i]
					i += 1
					local val16 = (bit.shift firstByte 8) + secondByte  -- Combine as 16-bit big-endian
					val16 = bit.and val16 0x3FFF                       -- Clear top 2 bits
					append results (bit.shift val16 2)                             -- Left-shift to restore original
					)
				else if top2 == 0xC0 then (
					-- 4-byte case: top bits = '11'
					if (i + 2) > byteArray.count do exit  -- Ensure enough bytes remain
					local b2 = byteArray[i]
					local b3 = byteArray[i+1]
					local b4 = byteArray[i+2]
					i += 3
					
					local val32 = (bit.shift firstByte 24) \
								+ (bit.shift b2 16) \
								+ (bit.shift b3 8) \
								+ b4  -- Combine as 32-bit big-endian
					val32 = bit.and val32 0x3FFFFFFF      -- Clear top 2 bits
					append results (bit.shift val32 2)               -- Left-shift to restore original
					)
				)
			results
			),
		
		fn read f = (
			
			fileid = f.read_ulong()
			count = f.read_ulong()
			encoding = #()
			offsets = #()
			if count > 0 do (
				encoding[count] = 0
				for i = 1 to count do (
					encoding[i] = f.read_ubyte()
					)
				offsets = decode(encoding)
				
				--print "DECODED"
				--format "#("
				--for s in offsets do (format "%, " s)
				--format ")\n"
				)
			),
		
		fn write &s = (
			-- I padded the stream since the faces are, but i'm not sure if i'm suppose to in this manner?
			s.write_ulong(fileid)
			encoding = encode(offsets)
			
			--print "\nRAW"
			--format "#("
			--for s in offsets do (format "%, " s)
			--format ")\n"
			
			--print "\nENCODED"
			--format "#("
			--for s in encoding do (format "%, " s)
			--format ")\n"
			
			count = encoding.count
			local padding = mod (4-(mod count 4)) 4
			s.write_ulong(count + padding)
			for i = 1 to count do (
				s.write_ubyte(encoding[i])
				)
			for i = 1 to padding do (
				s.write_ubyte(0)
				)
			)
		)
	
	struct TexEntry_t ( -- 32 bytes
		/*string*/ filename    = "",
		/*string*/ extension   = "",
		/*uint32*/ file_size   = 0, -- does not include the padding size
		/*uint32*/ data_offset = 0, -- absolute, from start of file
		/*uint32*/ reserved    = 0,
		
		fn read f = (
			filename = f.read_string length:0x10
			extension = f.read_string length:0x04
			file_size = f.read_ulong()
			data_offset = f.read_ulong()
			reserved = f.read_ulong()
			),
		
		fn write &s = (
			s.write_string filename length:0x10
			s.write_string extension length:0x04
			s.write_ulong(file_size)
			s.write_ulong(data_offset)
			s.write_ulong(reserved)
			)
		)

	struct Tex_t ( -- 16 bytes + n bytes
		/*uint32*/ entry_count  = 0,
		/*uint32*/ version      = 0x00000100,
		/*uint32*/ reserved     = 0x00000000,
		/*uint32*/ table_offset = 0x0010, -- Fixed offset for the entry table
		
		/*TexEntry_t[]*/ entries = #(),
		/*uint8[][]*/ files     = #(),
		
		fn read f outpath:"" = (
			local pos = f.tell()
			entry_count = f.read_ulong()
			version = f.read_ulong()
			entries = #()
			files = #()
			
			if entry_count > 0 then (
				reserved = f.read_ulong()
				table_offset = f.read_ulong()
				
				if entry_count > 0 then (
					entries[entry_count] = TexEntry_t()
					f.seek(table_offset)
					for i = 1 to entry_count do (
						entries[i] = TexEntry_t()
						entries[i].read(f)
						)
					
					if outpath == "" then (
						-- Store Data
						files[entry_count] = byteArray()
						
						for i = 1 to entry_count do (
							f.seek(pos + entries[i].data_offset)
							files[i] = byteArray()
							files[i].readFromStream f.bstream fsize:entries[i].file_size 
							)
						)
					else (
						-- Directly Write Data
						if substring outpath outpath.count 1 != "\\" do (
							outpath += "\\"
							)
						
						local folder = "0000" + (bit.IntAsHex version)
						folder = outpath + (substring folder (folder.count - 3) (folder.count + 4))
						
						if not doesDirectoryExist folder do (
							makeDir folder all:true
							)
						
						
						for file in entries do (
							if file.file_size == 0 do continue
							local s = try(fopen (folder + "\\" + file.filename + "." + file.extension) "wb")catch(undefined)
							if s != undefined do (
								
								local count = (file.file_size / 4) as integer
								local leftover = (mod file.file_size 4) as integer
								
								f.seek(pos + file.data_offset)
								
								if (count + leftover) > 0 and (pos + file.data_offset + file.file_size) <= f.size then (
									for i = 1 to count do (writeLong s (readLong f.bstream))
									for i = (1 + count) to (count + leftover) do (writeByte s (readByte f.bstream))
									)
								else (
									format "failed to write file {%}\n" file.filename
									print file
									)
								
								fclose s
								)
							)
						)
					
					) else (format "Invalid File Header\n")
				) else (format "Wrong Version?\n")
			),
		
		fn dump outpath = (
			
			entry_count = entries.count
			if entry_count > 0 and entry_count == files.count do (
				
				if substring outpath outpath.count 1 != "\\" do (
					outpath += "\\"
					)
				
				local folder = "0000" + (bit.IntAsHex version)
				folder = (substring folder (folder.count - 3) (folder.count + 4))
				
				local buildFolder = false or (doesDirectoryExist folder)
				
				for i = 1 to entry_count do (
					
					if entries[i].file_size == 0 or classof files[i] != byteArray or files[i].size == 0 do continue
					
					if not buildFolder do (makeDir folder all:true)
					
					local s = try(fopen (folder + "\\" + entries[i].filename + "." + entries[i].extension) "wb")catch(undefined)
					if s != undefined do (
						
						files[i].writeToStream(&s)
						
						fclose s
						)
					)
				)
			),
		

		fn write &s = (
			s.write_ulong(entry_count = files.count)
			s.write_ulong(version)
			s.write_ulong(reserved = 0)
			s.write_ulong(table_offset = 0x10)
			if entry_count > 0 and entries.count == files.count then (
				
				local ptr = 0
				local padding = #()
				padding[entry_count] = 0
				
				for i = 1 to entry_count do (
					entries[i].data_offset = ptr
					entries[i].file_size = 0
					if classof files[i] == byteArray do (
						entries[i].file_size = files[i].size
						)
					padding[i] = mod (4 - (mod entries[i].file_size 4)) 4
					ptr += entries[i].file_size + padding[i]
					entries[i].write(&s)
					)
				for i = 1 to entry_count do (
					if classof files[i] == byteArray do (
						files[i].writeToStream(&s.bstream)
						)
					for j = 1 to padding[i] do (
						writeByte s.bstream 0
						)
					)
				) else (format "file to entry mismatch, or no files\n")
			),
		
		fn pack folder directWrite:false = (
			
			if substring folder folder.count 1 != "\\" do (
				folder += "\\"
				)
			local out_file = (subString folder 1 (folder.count - 1)) + ".tex"
			
			local folder_files = getFiles (folder + "*.dds")
			entry_count = folder_files.count
			
			if entry_count > 0 do (
				
				-- Try to get the folder ID
				local ss = filterString folder "\\/"
				version = try(bit.HexAsInt("0x" + ss[ss.count]))catch(0)
				
				entries = #()
				entries[entry_count] = TexEntry_t()
				for i = 1 to entry_count do (
					entries[i] = TexEntry_t()
					entries[i].filename = getFilenameFile folder_files[i]
					entries[i].extension = subString (getFilenameType folder_files[i]) 2 -1
					entries[i].file_size = getFileSize folder_files[i]
					)
				
				if directWrite then (
					local write_file = subString folder 1 (folder.count - 1)
					
					-- Write Header File
					s = try(fopen (folder + "tex_header.tmp") "wb")catch(undefined)
					local dosStr = ""
					if s != undefined do (
						
						writelong s entry_count #unsigned
						writelong s version #unsigned
						writelong s 0x0000 #unsigned
						writelong s 0x0010 #unsigned -- table Offset
						local cur = 0
						dosStr += "copy \"" + folder + "tex_header.tmp\" /b + "
						for i = 1 to entry_count do (
							for j = 1 to 16 do (
								local b = 0
								if j <= entries[i].filename.count then (
									b = bit.CharAsInt(subString entries[i].filename j 1)
									)
								writeByte s b
								)
							for j = 1 to 4 do (
								local b = 0
								if j <= entries[i].extension.count then (
									b = bit.CharAsInt(subString entries[i].extension j 1)
									)
								writeByte s b
								)
							writelong s entries[i].file_size #unsigned
							writelong s cur #unsigned
							writelong s 0x00 #unsigned
							cur += entries[i].file_size
							
							dosStr += "\""+ folder_files[i] + "\" /b "
							if i != entry_count do (
								dosStr += "+ "
								)
							)
						fclose s
						dosStr += "\""+ write_file + ".tex\""
						--DOSCommand dosStr
						HiddenDOSCommand dosStr
						deleteFile (folder + "tex_header.tmp")
						)
					)
				else (
					files = #()
					files[entry_count] = byteArray()
					for i = 1 to entry_count do (
						files[i] = byteArray()
						
						local f = try(fopen folder_files[i] "rb")catch(undefined)
						if f != undefined do (
							
							files[i].readFromStream &f fsize:entries[i].file_size
							fclose f
							)
						)
					local s = bytestream()
					
					if s.open out_file mode:"wb" do (
						write(&s)
						s.close()
						)
					
					)
				)
			
			)
		)
	
	struct PachEntry_t ( -- 12 bytes
		/*uint16*/ file_index = 0,
		/*uint16*/ path_index = 0,
		/*uint32*/ addr       = 0,
		/*uint32*/ size       = 0,
		
		fn read f = (
			file_index = readshort f #unsigned
			path_index = readshort f #unsigned
			addr       = readlong  f #unsigned
			size       = readlong  f #unsigned
			),

		fn write &s = (
			writeshort s file_index #unsigned
			writeshort s path_index #unsigned
			writelong  s addr       #unsigned
			writelong  s size       #unsigned
			)
		)

	struct Pach_t ( -- 8 bytes + n bytes
		/*uint32*/ magic = 0x48434150,  -- 'Pach'
		/*uint32*/ count = 0,          -- number of entries
		
		/*PachEntry_t[]*/ entries = #(),
		/*uint8[][]*/    files   = #(),   -- in-memory file data
		
		fn read f outpath:"" = (
			magic = readlong f #unsigned
			if magic != 0x48434150 then (
				format "Invalid File ID (expected 'Pach')\n"
				return undefined
				)

			count = readlong f #unsigned
			entries = #()
			files   = #()

			if count > 0 do (
				-- Read the entry table
				entries[count] = PachEntry_t()
				for i = 1 to count do (
					entries[i] = PachEntry_t()
					entries[i].read(f)
					)

				local pos = ftell f  -- position right after the table

				if outpath == "" then (
					-- Store data in-memory
					files[count] = #()
					for i = 1 to count do (
						fseek f (pos + entries[i].addr) #seek_set
						local sz = entries[i].size
						files[i] = #()
						if sz > 0 do (
							files[i][sz] = 0  -- pre-allocate
							for b = 1 to sz do (
								files[i][b] = readbyte f #unsigned
								)
							)
						)
					) else (
					-- Write directly to disk
					-- Ensure trailing slash
					if substring outpath outpath.count 1 != "\\" do (
						outpath += "\\"
						)
					-- Create folder if needed
					if not doesDirectoryExist outpath do (
						makeDir outpath all:true
						)

					for i = 1 to count do (
						local sz = entries[i].size
						if sz > 0 then (
							fseek f (pos + entries[i].addr) #seek_set
							
							local filename = (entries[i].file_index as string) + "_" + (entries[i].path_index as string) 
							local fullPath = outpath + filename
							local s = try(fopen fullPath "wb") catch(undefined)
							if s != undefined do (
								-- Write the file data + alignment read
								-- We'll read in multiples of 4 for efficiency
								local count4   = (sz / 4) as integer
								local leftover = (mod sz 4)
								
								for c = 1 to count4 do (
									local val = readlong f #unsigned
									writelong s val #unsigned
									)
								for c = 1 to leftover do (
									local val = readbyte f #unsigned
									writebyte s val #unsigned
									)
								fclose s
								)
							)
						)
					)
				)
			),

		fn dump outpath = (
			if count > 0 and (entries.count == files.count) then (
				-- Ensure trailing slash
				if substring outpath outpath.count 1 != "\\" do (
					outpath += "\\"
					)
				if not doesDirectoryExist outpath do (
					makeDir outpath all:true
					)

				for i = 1 to count do (
					local sz = entries[i].size
					if sz > 0 and files[i].count == sz do (
						local filename = (entries[i].file_index as string) + "_" + (entries[i].path_index as string)
						local s = try(fopen (outpath + filename) "wb") catch(undefined)
						if s != undefined do (
							for b = 1 to sz do (
								writebyte s files[i][b] #unsigned
								)
							fclose s
							)
						)
					)
				) else (
				format "Nothing to dump or mismatch in entries/files\n"
				)
			),

		fn pack folder directWrite:false = (
			if substring folder folder.count 1 != "\\" do (
				folder += "\\"
				)
			
			local folder_files = getFiles (folder + "*.*")
			count = folder_files.count
			
			if count > 0 do (
				entries = #()
				entries[count] = PachEntry_t()
				
				for i = 1 to count do (
					local fpath = folder_files[i]
					local fname = getFilenameFile fpath
					-- you might interpret file_index & path_index differently
					-- For example, file_index = i, path_index = 0
					-- or parse them from the filename somehow.
					entries[i] = PachEntry_t()
					entries[i].file_index = i
					entries[i].path_index = 0
					entries[i].addr = 0   -- will be computed at write time
					entries[i].size = getFileSize fpath
					)
				
				if directWrite then (
					--------------------------------------------------------------------
					-- Directly build .pach on disk using DOS copy /b + padding
					--------------------------------------------------------------------
					local pachOut = folder + "packed.pach"
					local hdrTmp  = folder + "pach_header.tmp"
					local padTmp  = folder + "pad.tmp"
					
					local s = try(fopen hdrTmp "wb") catch(undefined)
					if s != undefined do (
						-- Write the 8-byte header
						writelong s magic #unsigned
						writelong s count #unsigned
						
						-- We'll compute addresses as we go
						local ptr = 0
						for i = 1 to count do (
							-- Write each PachEntry_t
							writeshort s entries[i].file_index #unsigned
							writeshort s entries[i].path_index #unsigned
							writelong  s (entries[i].addr = ptr) #unsigned
							writelong  s entries[i].size     #unsigned
							-- next address will move by size + alignment
							local leftover = mod (4 - (mod entries[i].size 4)) 4
							ptr += entries[i].size + leftover
							)
						fclose s
						)
					
					----------------------------------------------------------------
					-- Build DOS command: copy /b "pach_header.tmp" + each file + padding
					----------------------------------------------------------------
					local dosStr = ""
					dosStr += "copy /b \"" + hdrTmp + "\" + "
					
					for i = 1 to count do (
						local sz = entries[i].size
						local leftover = mod (4 - (mod sz 4)) 4
						local fpath = folder_files[i]
						
						dosStr += "\"" + fpath + "\""
						
						-- If leftover > 0, we create a tiny pad file
						if leftover > 0 then (
							-- Make the pad file
							local p = try(fopen padTmp "wb") catch(undefined)
							if p != undefined do (
								for b = 1 to leftover do (writebyte p 0 #unsigned)
								fclose p
								)
							dosStr += " + \"" + padTmp + "\""
							)
						
						if i < count then (
							dosStr += " + "
							)
						)
					
					-- Final target
					dosStr += " \"" + pachOut + "\""
					
					HiddenDOSCommand dosStr
					
					-- Cleanup
					deleteFile hdrTmp
					if doesFileExist padTmp do deleteFile padTmp
					
					)
				else (
					--------------------------------------------------------------------
					-- Load files into memory
					--------------------------------------------------------------------
					files = #()
					files[count] = #()
					for i = 1 to count do (
						local fpath = folder_files[i]
						local sz = entries[i].size
						files[i] = #()
						
						local f = try(fopen fpath "rb") catch(undefined)
						if f != undefined and sz > 0 do (
							files[i][sz] = 0
							for b = 1 to sz do (
								files[i][b] = readbyte f #unsigned
								)
							fclose f
							)
						)
					)
				)
			),

		fn write &s = (
			-- We assume 'files' in memory
			count = files.count
			if (count > 0) and (entries.count == count) then (
				-- Write the 8-byte header
				writelong s magic #unsigned
				writelong s count #unsigned
				
				-- Pre-calculate addresses + alignment
				local ptr = 0
				local padding = #()
				padding[count] = 0
				
				-- Write the entry table
				for i = 1 to count do (
					entries[i].addr = ptr
					entries[i].size = files[i].count  -- in-memory size
					writeshort s entries[i].file_index #unsigned
					writeshort s entries[i].path_index #unsigned
					writelong  s entries[i].addr       #unsigned
					writelong  s entries[i].size       #unsigned
					
					local leftover = mod (4 - (mod entries[i].size 4)) 4
					padding[i] = leftover
					ptr += entries[i].size + leftover
					)
				
				-- Write the raw file data + 0-padding
				for i = 1 to count do (
					local sz = entries[i].size
					for b = 1 to sz do (
						writebyte s files[i][b] #unsigned
						)
					for p = 1 to padding[i] do (
						writebyte s 0 #unsigned
						)
					)
				) else (
				format "No files or mismatch between 'entries' and 'files'\n"
				)
			)
		)

	struct Object_t ( -- 32 bytes
		/*char[16]*/ name = "",
		/*uint32*/ unk054 = 1, -- always 1
		/*uint32*/ unk055 = 0, -- always 0
		/*uint32*/ num_textures = 0, -- how many textures to read from texture string buffer
		/*uint32*/ unk057 = 0, -- always 0
		
		fn read f = (
			name = f.read_string length:16
			unk054 = f.read_ulong()
			unk055 = f.read_ulong()
			num_textures = f.read_ulong()
			unk057 = f.read_ulong()
			),
		
		fn write &s = (
			s.write_string name length:16
			s.write_ulong(unk054)
			s.write_ulong(unk055)
			s.write_ulong(num_textures)
			s.write_ulong(unk057)
			)
		)
	
	struct Atari_t ( -- 16 bytes
		/*
			the data seems to switch from little endian to big endian
			maybe they store stuff here optionally, or its just garbage bytes
		*/
		-- in little endian
		/*float[3]*/ position = [0.0, 0.0, 0.0], -- Absolute position
		/*float*/    diameter = 0.0,
		
		fn read f = (
			-- should be reading in big endian, but capture the current state
			local cur_endian = f.swapBytes
			
			-- switch into little endian
			f.littleEndian()
			
			position = [f.read_float(), f.read_float(), f.read_float()]
			diameter = f.read_float()
			
			-- Restore existing endian
			f.swapBytes = cur_endian
			),
		
		fn write &s = (
			local cur_endian = s.swapBytes
			s.littleEndian()
			s.write_float(position[1])
			s.write_float(position[2])
			s.write_float(position[3])
			s.write_float(diameter)
			s.swapBytes = cur_endian
			)
		)
	
	struct Bone_t ( -- 80 bytes
		/*char[16]*/    bone_name       = "",                       -- Bone name
		/*float[3]*/    bone_position   = #(0.0, 0.0, 0.0, 0.0),    -- Position of the bone, W component is always 0, relative position
		/*float[4]*/    bone_rotation   = #(0.0, 0.0, 0.0, 0.0),    -- Rotation of the bone, W component is always 0, relative rotation, Euler as Radians
		/*int32*/       bone_parent     = -1,                       -- Parent bone index
		/*uint32[3]*/   unknown         = #(0, 0, 0),               -- padding? always 0 0 0
		/*Atari_t*/     atari           = Atari_t(),    -- End position of the bone
		
		fn printInfo = (
			format "Bone Name: \t%\n" bone_name
			format "Position: \t[%f, %f, %f]\n" bone_position[1] bone_position[2] bone_position[3]
			format "Rotation: \t[%f, %f, %f, %f]\n" bone_rotation[1] bone_rotation[2] bone_rotation[3] bone_rotation[4]
			format "Parent Index: \t%\n" bone_parent
			format "Unknown: \t[%d, %d, %d]\n" unknown[1] unknown[2] unknown[3]
			format "Atari: \t[%f, %f, %f, %f]\n" atari.position[1] atari.position[2] atari.position[3] atari.diameter
			),
		
		fn read f = (
			bone_name = f.read_string length:16
			bone_position = #(f.read_float(), f.read_float(), f.read_float(), f.read_float())
			bone_rotation = #(f.read_float(), f.read_float(), f.read_float(), f.read_float())
			bone_parent = f.read_ulong()
			unknown = #(f.read_long(), f.read_long(), f.read_long())
			atari.read(f)
			),
		
		fn write &s = (
			s.write_string bone_name length:16
			for val in bone_position do s.write_float(val)
			for val in bone_rotation do s.write_float(val)
			s.write_ulong(bone_parent)
			for val in unknown do s.write_long(val)
			atari.write(&s)
			)
		)
	
	struct Face_t ( -- 12 bytes
		/*uint32*/ type          = 6, -- Always 6
		/*uint32*/ face_count    = 0,
		/*uint32*/ face_offset   = 0,
		
		/*uint16*/ faces         = #(),
		
		fn asTriangles start count &faceArray &matIDArray face_add:1 vertex_start:0 matid:1 = (
			
			local fa,fb,fc,x=0,y
			local face_flip = true
			local face_reset=true
			while x < count do (
				x+=1
				if face_reset == true then (
					
					face_reset=false
					face_flip = false
					append matIDArray matid
					fa = (faces[start + x]-vertex_start) + face_add
					fb = (faces[start + x + 1]-vertex_start) + face_add
					fc = (faces[start + x + 2]-vertex_start) + face_add
					x+=2
					if face_flip == true then (
						append faceArray [fa,fb,fc]
						face_flip=false
						)
					else(
						append faceArray [fa,fc,fb]
						face_flip=true
						)
					)
				else (
					fa = fb
					fb = fc
					fc = faces[start + x]
					if fc < 0xFFFF and fc > -1 then (
						
						
						fc-= vertex_start
						fc += face_add
						
						local degen_face = fa != fb and fb != fc and fc != fa
						
						if degen_face do append matIDArray matid
						if face_flip == true then (
							if degen_face do append faceArray [fa,fb,fc]
							face_flip=false
							)
						else(
							if degen_face do append faceArray [fa,fc,fb]
							face_flip=true
							)
							
						
						)
					else(
						face_reset=true
						)
					)
				)
			),
		
		fn read f = (
			type = f.read_ulong()
			face_count = f.read_ulong()
			face_offset = f.read_ulong()
			),
		
		fn write &s = (
			s.write_ulong(type)
			s.write_ulong(face_count)
			s.write_ulong(face_offset)
			)
		)
	
	struct Vertex_t ( -- 28 bytes
		
		/*float[3]*/ position = [0.0, 0.0, 0.0],
		/*float[3]*/ normal   = [0.0, 0.0, 0.0],
		/*uint8[4]*/ colour   = #(0, 0, 0, 255),
		
		fn read f = (
			position          = [f.read_float(), f.read_float(), f.read_float()]
			normal            = [f.read_float(), f.read_float(), f.read_float()]
			colour            = #(f.read_ubyte(), f.read_ubyte(), f.read_ubyte(), f.read_ubyte())
			),
		
		fn write &s = (
			s.write_float(position[1])
			s.write_float(position[2])
			s.write_float(position[3])
			s.write_float(normal[1])
			s.write_float(normal[2])
			s.write_float(normal[3])
			s.write_ubyte(colour[1])
			s.write_ubyte(colour[2])
			s.write_ubyte(colour[3])
			s.write_ubyte(colour[4])
			)
		)
	
	struct Material_t ( -- 20 + n bytes
		/*char[16]*/ type     = "",
		/*uint16*/ entry_type = 0, -- {5 10 13 15 16 }
		/*uint16*/ entry_size = 0, -- {24 36 }
		
		/*void**/ data        = #(),
		
		/* MIN MAX VALUES
		g_bDiffTangent -> Min: 0.0, Max: 0.0
		g_bDrawWrinkle -> Min: 0.0, Max: 1.0
		g_bReflectAdd -> Min: 0.0, Max: 1.0
		g_bUseGlow -> Min: 0.0, Max: 0.0
		g_bUseRefCube -> Min: 0.0, Max: 1.0
		g_bUseRefRegMap -> Min: 0.0, Max: 1.0
		g_f2WrinkleRegU -> Min: 0.0, Max: 0.5
		g_f2WrinkleRegV -> Min: 0.0, Max: 0.5
		g_f4BruiseCol -> Min: 0.0, Max: 1.0
		g_f4Fairy -> Min: 0.0, Max: 5.0
		g_f4FairyColorC -> Min: 0.701961, Max: 4.0
		g_f4FairyColorO -> Min: 0.6, Max: 1.5
		g_f4FairyLv -> Min: 0.0, Max: 5.0
		g_f4MatAmbCol -> Min: 0.0, Max: 1.0
		g_f4MatDifCol -> Min: 0.0, Max: 1.0
		g_f4Scale -> Min: 0.00554, Max: 1.0
		g_f4SpecularCol -> Min: 0.0, Max: 1.5
		g_f4TileEffVal -> Min: 0.0, Max: 5.0
		g_fAmbOccDif -> Min: 0.0, Max: 1.0
		g_fAmbOccLev -> Min: 0.0, Max: 1.0
		g_fBruiseLev -> Min: 0.0, Max: 0.0
		g_fHDRAlpha -> Min: 0.0, Max: 100.0
		g_fNoizeSpeed -> Min: 0.0018, Max: 0.0018
		g_fReflectAlpha -> Min: 0.0, Max: 1.0
		g_fSL_Scale -> Min: 0.004, Max: 0.04
		g_fScrollU -> Min: -1.0, Max: 50.0
		g_fScrollU2 -> Min: -0.2, Max: 2.5
		g_fScrollU3 -> Min: -0.2, Max: 0.0
		g_fScrollU4 -> Min: 0.0, Max: 0.0
		g_fScrollV -> Min: -2.0, Max: 2.0
		g_fScrollV2 -> Min: -3.0, Max: 0.4
		g_fScrollV3 -> Min: 0.0, Max: 0.0
		g_fScrollV4 -> Min: 0.0, Max: 0.0
		g_fSpecularLev -> Min: 0.0, Max: 10.0
		g_fSweatLev -> Min: 0.0, Max: 0.0
		g_fSweatSPA -> Min: 0.0, Max: 80.0
		g_fTileCountU -> Min: 1.0, Max: 200.0
		g_fTileCountV -> Min: 1.0, Max: 200.0
		g_fTileEffSw -> Min: 0.0, Max: 0.0
		g_fWaveSpeed -> Min: 0.001, Max: 0.0034
		g_fWrinkleBlend -> Min: 0.5, Max: 0.5
		g_fvLightLimit -> Min: 1.0, Max: 100.0
		g_iBruiseParts -> Min: 0.0, Max: 0.0
		g_iSpecularPow -> Min: 0.0, Max: 300.0
		g_iWrinkleParts -> Min: 0.0, Max: 0.0
		
		*/
		/* === Parameters Used by Each Known Shader ===
		
		Shader: yBumpMap
		Found 14 parameters:
		  g_bReflectAdd
		  g_bUseRefRegMap
		  g_f4MatAmbCol
		  g_f4MatDifCol
		  g_f4SpecularCol
		  g_fHDRAlpha
		  g_fReflectAlpha
		  g_fSpecularLev
		  g_iSpecularPow
		  texDiffuse
		  texNormal
		  texRefctionReg
		  texSpecularMap
		  texSphRefction

		Shader: yBumpMapSS
		Found 33 parameters:
		  g_bDiffTangent
		  g_bDrawWrinkle
		  g_f2WrinkleRegU
		  g_f2WrinkleRegV
		  g_f4BruiseCol
		  g_f4Fairy
		  g_f4FairyColorC
		  g_f4FairyColorO
		  g_f4FairyLv
		  g_f4MatAmbCol
		  g_f4MatDifCol
		  g_f4SpecularCol
		  g_f4TileEffVal
		  g_fAmbOccDif
		  g_fAmbOccLev
		  g_fBruiseLev
		  g_fHDRAlpha
		  g_fSpecularLev
		  g_fSweatLev
		  g_fSweatSPA
		  g_fTileCountU
		  g_fTileCountV
		  g_fTileEffSw
		  g_fWrinkleBlend
		  g_fvLightLimit
		  g_iBruiseParts
		  g_iSpecularPow
		  g_iWrinkleParts
		  texDiffuse
		  texNormal
		  texOcclusion
		  texTilingMap
		  texWrinkleMap

		Shader: yDefault
		Found 10 parameters:
		  g_bUseGlow
		  g_f4MatAmbCol
		  g_f4MatDifCol
		  g_f4SpecularCol
		  g_fHDRAlpha
		  g_fSpecularLev
		  g_iSpecularPow
		  g_texDiffuse
		  texDiffuse
		  texSpecularMap

		Shader: yReflect
		Found 18 parameters:
		  g_bReflectAdd
		  g_bUseRefCube
		  g_bUseRefRegMap
		  g_f4MatAmbCol
		  g_f4MatDifCol
		  g_f4SpecularCol
		  g_fAmbOccDif
		  g_fAmbOccLev
		  g_fHDRAlpha
		  g_fReflectAlpha
		  g_fSpecularLev
		  g_iSpecularPow
		  texCubeRefction
		  texDiffuse
		  texOcclusion
		  texRefctionReg
		  texSpecularMap
		  texSphRefction

		Shader: ySilhouette
		Found 1 parameters:
		  texDiffuse

		Shader: yUVScroll
		Found 20 parameters:
		  g_f4MatAmbCol
		  g_f4MatDifCol
		  g_f4SpecularCol
		  g_fHDRAlpha
		  g_fSL_Scale
		  g_fScrollU
		  g_fScrollU2
		  g_fScrollU3
		  g_fScrollU4
		  g_fScrollV
		  g_fScrollV2
		  g_fScrollV3
		  g_fScrollV4
		  g_fSpecularLev
		  g_iSpecularPow
		  texDiffuse
		  texSpecularMap
		  texUVScroll2
		  texUVScroll3
		  texUVScroll4

		Shader: yWater
		Found 12 parameters:
		  g_f4MatAmbCol
		  g_f4MatDifCol
		  g_f4Scale
		  g_f4SpecularCol
		  g_fHDRAlpha
		  g_fNoizeSpeed
		  g_fSpecularLev
		  g_fWaveSpeed
		  g_iSpecularPow
		  texCubeRefction
		  texDiffuse
		  texNoizeMap
		*/
		
		known_params = #(
			"g_bDiffTangent",
			"g_bDrawWrinkle",
			"g_bReflectAdd",
			"g_bUseGlow",
			"g_bUseRefCube",
			"g_bUseRefRegMap",
			"g_f2WrinkleRegU",
			"g_f2WrinkleRegV",
			"g_f4BruiseCol",
			"g_f4BruiseCol",
			"g_f4Fairy",
			"g_f4FairyColorC",
			"g_f4FairyColorO",
			"g_f4FairyLv",
			"g_f4MatAmbCol",
			"g_f4MatDifCol",
			"g_f4Scale",
			"g_f4SpecularCol",
			"g_f4TileEffVal",
			"g_fvLightLimit",
			"g_fAmbOccDif",
			"g_fAmbOccLev",
			"g_fBruiseLev",
			"g_fHDRAlpha",
			"g_fNoizeSpeed",
			"g_fReflectAlpha",
			"g_fScrollU",
			"g_fScrollU2",
			"g_fScrollU3",
			"g_fScrollU4",
			"g_fScrollV",
			"g_fScrollV2",
			"g_fScrollV3",
			"g_fScrollV4",
			"g_fSL_Scale",
			"g_fSpecularLev",
			"g_fSweatLev",
			"g_fSweatSPA",
			"g_fTileCountU",
			"g_fTileCountV",
			"g_fTileEffSw",
			"g_fWaveSpeed",
			"g_fWrinkleBlend",
			"g_iBruiseParts",
			"g_iSpecularPow",
			"g_iWrinkleParts",
			"g_texDiffuse",
			"texDiffuse",
			"texCubeRefction",
			"texNoizeMap",
			"texNormal",
			"texOcclusion",
			"texRefctionReg",
			"texSpecularMap",
			"texSphRefction",
			"texTilingMap",
			"texUVScroll",
			"texUVScroll2",
			"texUVScroll3",
			"texUVScroll4",
			"texWrinkleMap"
			),
		
		fn size = (20 + (data.count * 4)),
		
		fn setMaxMaterialFlags &flag1 &flag2 &flag3 &flag4 = (
			/*
				create a bitmask for what paramter was stored
			*/
			case type of (
				
				"g_bDiffTangent" : flag1 = bit.set flag1  1 true
				"g_bDrawWrinkle" : flag1 = bit.set flag1  2 true
				"g_bReflectAdd"  : flag1 = bit.set flag1  3 true
				"g_bUseGlow"     : flag1 = bit.set flag1  4 true
				"g_bUseRefCube"  : flag1 = bit.set flag1  5 true
				"g_bUseRefRegMap": flag1 = bit.set flag1  6 true
				"g_f2WrinkleRegU": flag1 = bit.set flag1  7 true
				"g_f2WrinkleRegV": flag1 = bit.set flag1  8 true
				"g_f4BruiseCol"  : flag1 = bit.set flag1  9 true
				"g_f4Fairy"      : flag1 = bit.set flag1 10 true
				"g_f4FairyColorC": flag1 = bit.set flag1 11 true
				"g_f4FairyColorO": flag1 = bit.set flag1 12 true
				"g_f4FairyLv"    : flag1 = bit.set flag1 13 true
				"g_f4MatAmbCol"  : flag1 = bit.set flag1 14 true
				"g_f4MatDifCol"  : flag1 = bit.set flag1 15 true
				"g_f4Scale"      : flag1 = bit.set flag1 16 true
				
				"g_f4SpecularCol": flag2 = bit.set flag2  1 true
				"g_f4TileEffVal" : flag2 = bit.set flag2  2 true
				"g_fAmbOccDif"   : flag2 = bit.set flag2  3 true
				"g_fAmbOccLev"   : flag2 = bit.set flag2  4 true
				"g_fBruiseLev"   : flag2 = bit.set flag2  5 true
				"g_fHDRAlpha"    : flag2 = bit.set flag2  6 true
				"g_fNoizeSpeed"  : flag2 = bit.set flag2  7 true
				"g_fReflectAlpha": flag2 = bit.set flag2  8 true
				"g_fScrollU"     : flag2 = bit.set flag2  9 true
				"g_fScrollU2"    : flag2 = bit.set flag2 10 true
				"g_fScrollU3"    : flag2 = bit.set flag2 11 true
				"g_fScrollU4"    : flag2 = bit.set flag2 12 true
				"g_fScrollV"     : flag2 = bit.set flag2 13 true
				"g_fScrollV2"    : flag2 = bit.set flag2 14 true
				"g_fScrollV3"    : flag2 = bit.set flag2 15 true
				"g_fScrollV4"    : flag2 = bit.set flag2 16 true
				
				"g_fSL_Scale"    : flag3 = bit.set flag3  1 true
				"g_fSpecularLev" : flag3 = bit.set flag3  2 true
				"g_fSweatLev"    : flag3 = bit.set flag3  3 true
				"g_fSweatSPA"    : flag3 = bit.set flag3  4 true
				"g_fTileCountU"  : flag3 = bit.set flag3  5 true
				"g_fTileCountV"  : flag3 = bit.set flag3  6 true
				"g_fTileEffSw"   : flag3 = bit.set flag3  7 true
				"g_fvLightLimit" : flag3 = bit.set flag3  8 true
				"g_fWaveSpeed"   : flag3 = bit.set flag3  9 true
				"g_fWrinkleBlend": flag3 = bit.set flag3 10 true
				"g_iBruiseParts" : flag3 = bit.set flag3 11 true
				"g_iSpecularPow" : flag3 = bit.set flag3 12 true
				"g_iWrinkleParts": flag3 = bit.set flag3 13 true
				
				"g_texDiffuse"   : flag4 = bit.set flag4  1 true
				"texCubeRefction": flag4 = bit.set flag4  2 true
				"texDiffuse"     : flag4 = bit.set flag4  3 true
				"texNoizeMap"    : flag4 = bit.set flag4  4 true
				"texNormal"      : flag4 = bit.set flag4  5 true
				"texOcclusion"   : flag4 = bit.set flag4  6 true
				"texRefctionReg" : flag4 = bit.set flag4  7 true
				"texSpecularMap" : flag4 = bit.set flag4  8 true
				"texSphRefction" : flag4 = bit.set flag4  9 true
				"texTilingMap"   : flag4 = bit.set flag4 10 true
				"texUVScroll"    : flag4 = bit.set flag4 11 true
				"texUVScroll2"   : flag4 = bit.set flag4 12 true
				"texUVScroll3"   : flag4 = bit.set flag4 13 true
				"texUVScroll4"   : flag4 = bit.set flag4 14 true
				"texWrinkleMap"  : flag4 = bit.set flag4 15 true
				"texShimmer"     : flag4 = bit.set flag4 16 true
				)
			),
		
		fn read f = (
			type = f.read_string length:16
			entry_type = f.read_ushort()
			entry_size = f.read_ushort()
			
			data = (
				case entry_type of (
					-- Integer
					0x05: #(f.read_ulong())
					
					-- Float
					0x0A: #(f.read_float())
					
					-- Float[4]
					0x0D: #(f.read_float(), f.read_float(), f.read_float(), f.read_float())
					
					-- Index
					0x0F: #(f.read_ulong())
					
					-- Boolean
					0x10: #(f.read_ulong())
					
					default: (
						format "Unknown Material Parameter {%}\n" type
						#()
						)
					)
				)
			--if entry_type == 0x0F do format "Index: \t% \t%\n" data[1] type
			--if entry_type == 0x0F and data[1] > arr1 do arr1 = data[1]
			
			if findItem known_params type == 0 do (
				format "%: \t%\n" type (data as string)
				)
			),
		
		fn write &s = (
			
			local TYPE_INTEGER = 0x05
			local TYPE_FLOAT   = 0x0A
			local TYPE_VECTOR  = 0x0D
			local TYPE_INDEX   = 0x0F
			local TYPE_BOOLEAN = 0x10
			
			s.write_string type length:16
			
			entry_size = 24
			if MatchPattern type pattern:"g_b*" then (
				-- Boolean
				s.write_ushort(entry_type = TYPE_BOOLEAN)
				s.write_ushort(entry_size)
				s.write_ulong(data[1])
				)
			else if MatchPattern type pattern:"g_f4*" or MatchPattern type pattern:"g_fv*" then (
				-- Vectorf 4
				s.write_ushort(entry_type = TYPE_VECTOR)
				s.write_ushort(entry_size = 36)
				for val in data do s.write_float(val)
				)
			else if MatchPattern type pattern:"g_f2*" then (
				-- Vectorf 2
				s.write_ushort(entry_type = TYPE_VECTOR)
				s.write_ushort(entry_size = 36)
				for val in data do s.write_float(val)
				)
			else if MatchPattern type pattern:"g_f*" then (
				-- float
				s.write_ushort(entry_type = TYPE_FLOAT)
				s.write_ushort(entry_size)
				s.write_float(data[1])
				)
			else if MatchPattern type pattern:"g_i*" then (
				-- int
				s.write_ushort(entry_type = TYPE_INTEGER)
				s.write_ushort(entry_size)
				s.write_ulong(data[1])
				)
			else if MatchPattern type pattern:"g_tex*" or MatchPattern type pattern:"tex*" then (
				-- index
				s.write_ushort(entry_type = TYPE_INDEX)
				s.write_ushort(entry_size)
				s.write_ulong(data[1])
				)
			else (
				format "Unknown Material Parameter {%}\n" type
				)
			)
		)
	
	struct Mesh_t ( -- 180 bytes *Note other data is being stored here
		/*uint32*/  vertex_count     = 0,                    -- Number of vertices
		/*uint32*/  element_count    = 0,                    -- Number of elements
		/*uint32*/  bone_map_count   = 0,                    -- Number of bones in the bone map, equal to equal to 20
		/*int32[20]*/bone_map        = #(-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1),-- Bone map indices, reserved 20
		/*uint32*/  num_bone_weights = 4,                    -- Number of bone weights
		/*uint32*/  group_index      = 0,                    -- Index to Object Names
		/*uint32*/  unk11            = 1,                    -- Always 1
		/*uint32*/  vertex_buf_offset= 0,                    -- Offset to vertex data
		/*uint32*/  weight_offset    = 0,                    -- Offset to weight data
		/*uint32*/  texcoord_offset  = 0,                    -- Offset to UVW data
		/*uint32*/  unk14            = 1,                    -- render priority ? safe to leave as 1 {0 1 2 3 4 5 6 7 9 10 }
		/* === Frequency of unk14 values ===
			unk14 = 1:  1267 occurrence(s)
			unk14 = 5:  3 occurrence(s)
			unk14 = 0:  3 occurrence(s)
			unk14 = 3:  3 occurrence(s)
			unk14 = 4:  3 occurrence(s)
			unk14 = 2:  3 occurrence(s)
			unk14 = 7:  1 occurrence(s)
			unk14 = 9:  1 occurrence(s)
			unk14 = 10:  1 occurrence(s)
			unk14 = 6:  1 occurrence(s)
		*/
		/*char[16]*/name             = "yBumpMap",           -- shader, crashes if not one of theses {yBumpMap, yBumpMapSS, yDefault, yReflect, ySilhouette, yUVScroll, yWater }
		/*uint32*/  unk15            = 4,                    -- ?? doesnt seem to do anything when changed {4 5 6 276 278 }
		/*uint32*/  unk16            = 3,                    -- ?? shader attributes, can crash game {0 1 2 3 4 5 6 7 8 }
		-- 0 transparent, with specular
		-- 1 transparent
		-- 2 transparent, with rimlight, with specular
		-- 3 transparent, with rimlight
		-- 4 Solid, with Normal map
		-- 5 No Shade?
		-- 6 Solid, with Rimlight
		-- 7 transparent, with rimlight ? same as 3
		-- 8 causes crash
		/*uint32*/  mat_param_count  = 0,                    -- Number of material properties
		/*uint32*/  mat_param_offset = 0,                    -- Offset to material properties
		/*uint32*/  element_offset   = 0,                    -- Offset to element data aka strips
		/*uint32*/  texcoord_count   = 0,                    -- T-vertex count, maybe UV count?
		/*uint32*/  unk21            = 0,                    -- Always 0
		/*float[4]*/bsphere          = #(0.0, 0.0, 0.0, 0.0),-- Position data (x, y, z, w)
		
		-- This Data gets read in after the main mesh read and is not really apart of the struct
		/*uint32*/  mat_param_addrs  = #(),
		/*Material_t[]*/mat_params   = #(
			(Material_t type:"g_bDiffTangent"   data:(#(1))),
			(Material_t type:"g_bDrawWrinkle"   data:(#(1))),
			(Material_t type:"g_bReflectAdd"    data:(#(1))),
			(Material_t type:"g_bUseGlow"       data:(#(1))),
			(Material_t type:"g_bUseRefCube"    data:(#(1))),
			(Material_t type:"g_bUseRefRegMap"  data:(#(1))),
			(Material_t type:"g_f2WrinkleRegU"  data:(#(1.0, 1.0, 0.0, 0.0))),
			(Material_t type:"g_f2WrinkleRegV"  data:(#(1.0, 1.0, 0.0, 0.0))),
			(Material_t type:"g_f4BruiseCol"    data:(#(0.3, 0.3, 0.3, 1.0))),
			(Material_t type:"g_f4BruiseCol"    data:(#(0.3, 0.3, 0.3, 1.0))),
			(Material_t type:"g_f4Fairy"        data:(#(1.0, 1.0, 1.0, 1.0))),
			(Material_t type:"g_f4FairyColorC"  data:(#(0.3, 0.3, 0.3, 1.0))),
			(Material_t type:"g_f4FairyColorO"  data:(#(1.0, 1.0, 1.0, 1.0))),
			(Material_t type:"g_f4FairyLv"      data:(#(1.0, 1.0, 1.0, 1.0))),
			(Material_t type:"g_f4MatAmbCol"    data:(#(0.3, 0.3, 0.3, 1.0))),
			(Material_t type:"g_f4MatDifCol"    data:(#(0.3, 0.3, 0.3, 1.0))),
			(Material_t type:"g_f4Scale"        data:(#(1.0, 1.0, 1.0, 1.0))),
			(Material_t type:"g_f4SpecularCol"  data:(#(1.0, 1.0, 1.0, 1.0))),
			(Material_t type:"g_f4TileEffVal"   data:(#(1.0, 1.0, 1.0, 1.0))),
			(Material_t type:"g_fvLightLimit"   data:(#(1.0, 1.0, 1.0, 1.0))),
			(Material_t type:"g_fAmbOccDif"     data:(#(1.0))),
			(Material_t type:"g_fAmbOccLev"     data:(#(1.0))),
			(Material_t type:"g_fBruiseLev"     data:(#(1.0))),
			(Material_t type:"g_fHDRAlpha"      data:(#(1.0))),
			(Material_t type:"g_fNoizeSpeed"    data:(#(1.0))),
			(Material_t type:"g_fReflectAlpha"  data:(#(1.0))),
			(Material_t type:"g_fScrollU"       data:(#(1.0))),
			(Material_t type:"g_fScrollU2"      data:(#(1.0))),
			(Material_t type:"g_fScrollU3"      data:(#(1.0))),
			(Material_t type:"g_fScrollU4"      data:(#(1.0))),
			(Material_t type:"g_fScrollV"       data:(#(1.0))),
			(Material_t type:"g_fScrollV2"      data:(#(1.0))),
			(Material_t type:"g_fScrollV3"      data:(#(1.0))),
			(Material_t type:"g_fScrollV4"      data:(#(1.0))),
			(Material_t type:"g_fSL_Scale"      data:(#(1.0))),
			(Material_t type:"g_fSpecularLev"   data:(#(1.0))),
			(Material_t type:"g_fSweatLev"      data:(#(1.0))),
			(Material_t type:"g_fSweatSPA"      data:(#(1.0))),
			(Material_t type:"g_fTileCountU"    data:(#(1.0))),
			(Material_t type:"g_fTileCountV"    data:(#(1.0))),
			(Material_t type:"g_fTileEffSw"     data:(#(1.0))),
			(Material_t type:"g_fWaveSpeed"     data:(#(1.0))),
			(Material_t type:"g_fWrinkleBlend"  data:(#(1.0))),
			(Material_t type:"g_iBruiseParts"   data:(#(0))),
			(Material_t type:"g_iSpecularPow"   data:(#(5))),
			(Material_t type:"g_iWrinkleParts"  data:(#(0))),
			(Material_t type:"g_texDiffuse"     data:(#(-1))),
			(Material_t type:"texDiffuse"       data:(#(-1))),
			(Material_t type:"texCubeRefction"  data:(#(-1))),
			(Material_t type:"texNoizeMap"      data:(#(-1))),
			(Material_t type:"texNormal"        data:(#(-1))),
			(Material_t type:"texOcclusion"     data:(#(-1))),
			(Material_t type:"texRefctionReg"   data:(#(-1))),
			(Material_t type:"texSpecularMap"   data:(#(-1))),
			(Material_t type:"texSphRefction"   data:(#(-1))),
			(Material_t type:"texShimmer"       data:(#(-1))),
			(Material_t type:"texTilingMap"     data:(#(-1))),
			(Material_t type:"texUVScroll"      data:(#(-1))),
			(Material_t type:"texUVScroll2"     data:(#(-1))),
			(Material_t type:"texUVScroll3"     data:(#(-1))),
			(Material_t type:"texUVScroll4"     data:(#(-1))),
			(Material_t type:"texWrinkleMap"    data:(#(-1)))
			),
		/*uint32*/  vertex_offset    = 0,
		/*Vertex_t[]*/vertices       = #(),
		/*int32[]*/bone_ids          = #(), -- little endian?
		/*float[]*/bone_weights      = #(),
		/*float[2][]*/texcoords      = #(),
		/*Face_t[]*/elements         = #(),
		-- there seems to be 12 bytes padding here sometimes?
		
		
		fn printInfo = (
			format "vertex_count: \t%\n" vertex_count
			format "element_count: \t%\n" element_count
			format "bone_map_count: \t%\n" bone_map.count
			format "bone_map: \t%\n" bone_map
			format "num_bone_weights: \t%\n" num_bone_weights
			format "vertex_buf_offset: \t%\n" ((vertex_buf_offset + 8) as integer)
			format "weight_offset: \t%\n" ((weight_offset + 8) as integer)
			format "texcoord_offset: \t%\n" ((texcoord_offset + 8) as integer)
			format "name: \t%\n" name
			format "mat_param_count: \t%\n" mat_param_count
			format "mat_param_offset: \t%\n" ((mat_param_offset + 8) as integer)
			format "element_offset: \t%\n" ((element_offset + 8) as integer)
			format "texcoord_count: \t%\n" texcoord_count
			format "group_index: \t%\n" group_index
			format "unk14: \t%\n" unk14
			format "unk15: \t%\n" unk15
			format "unk16: \t% -- 1 when texSphRefction, 3 when specMap valid, 6 spec, normal valid, 7 when spec, norm, sphRefc, refecReg\n" unk16
			format "unk11: \t%\n" unk11
			format "unk21: \t%\n" unk21
			format "\n\n-----------------------------------\n"
			),
		
		fn read f = (
			vertex_count        = f.read_ulong()
			element_count       = f.read_ulong()
			bone_map_count      = f.read_ulong()
			bone_map            = for x = 1 to bone_map_count collect f.read_long()
			f.seek(f.tell() + ((20 - bone_map_count) * 4)) -- skip the empties
			num_bone_weights    = f.read_ulong()
			group_index         = f.read_ulong()
			unk11               = f.read_ulong()
			vertex_buf_offset   = f.read_ulong()
			weight_offset       = f.read_ulong()
			texcoord_offset     = f.read_ulong()
			unk14               = f.read_ulong()
			name                = f.read_string length:16
			unk15               = f.read_ulong()
			unk16               = f.read_ulong()
			mat_param_count     = f.read_ulong()
			mat_param_offset    = f.read_ulong()
			element_offset      = f.read_ulong()
			texcoord_count      = f.read_ulong()
			unk21               = f.read_ulong()
			bsphere             = #(f.read_float(), f.read_float(), f.read_float(), f.read_float())
			
			--printInfo()
			),
		
		fn write &s = (
			s.write_ulong(vertex_count = vertices.count)
			s.write_ulong(element_count = elements.count)
			bone_map_count = 0
			for b in bone_map do (
				if b < 0 do exit
				bone_map_count += 1
				)
			if bone_map_count > 20 do bone_map_count = 20
			s.write_ulong(bone_map_count)
			for i = 1 to bone_map_count do s.write_long(bone_map[i]) -- Write only the valid bone_map entries
			for i = bone_map_count + 1 to 20 do s.write_long(-1) -- Fill remaining bone_map slots with -1
			s.write_ulong(num_bone_weights)
			s.write_ulong(group_index)
			s.write_ulong(unk11)
			s.write_ulong(vertex_buf_offset)
			s.write_ulong(weight_offset)
			s.write_ulong(texcoord_offset)
			s.write_ulong(unk14)
			s.write_string name length:16 -- Ensure fixed-length string
			s.write_ulong(unk15)
			s.write_ulong(unk16)
			s.write_ulong(mat_param_count = mat_params.count)
			s.write_ulong(mat_param_offset)
			s.write_ulong(element_offset)
			s.write_ulong(texcoord_count = texcoords.count)
			s.write_ulong(unk21)
			for i = 1 to 4 do s.write_float(bsphere[i]) -- Explicitly write each component of the bounding sphere
			),
		
		fn getParamsFromMat &mat &tex_names forceOn:false index_ofset:0 = (
			
			mat_params = #()
			
			if custAttributes.count mat > 0 then (
				
				--format "index_ofset: \t%\n" index_ofset
				local attr = custAttributes.get mat 1
				
				local enable1_flag = 0xFFFF
				local enable2_flag = 0xFFFF
				local enable3_flag = 0xFFFF
				local enable4_flag = 0xFFFF
				if isProperty mat #enable1 do (enable1_flag = attr.enable1)
				if isProperty mat #enable2 do (enable2_flag = attr.enable2)
				if isProperty mat #enable3 do (enable3_flag = attr.enable3)
				if isProperty mat #enable4 do (enable4_flag = attr.enable4)
				
				local g_bDiffTangent = bit.get enable1_flag  1
				local g_bDrawWrinkle = bit.get enable1_flag  2
				local g_bReflectAdd =  bit.get enable1_flag  3
				local g_bUseGlow =     bit.get enable1_flag  4
				local g_bUseRefCube =  bit.get enable1_flag  5
				local g_bUseRefRegMap =bit.get enable1_flag  6
				local g_f2WrinkleRegU =bit.get enable1_flag  7
				local g_f2WrinkleRegV =bit.get enable1_flag  8
				local g_f4BruiseCol =  bit.get enable1_flag  9
				local g_f4Fairy =      bit.get enable1_flag 10
				local g_f4FairyColorC =bit.get enable1_flag 11
				local g_f4FairyColorO =bit.get enable1_flag 12
				local g_f4FairyLv =    bit.get enable1_flag 13
				local g_f4MatAmbCol =  bit.get enable1_flag 14
				local g_f4MatDifCol =  bit.get enable1_flag 15
				local g_f4Scale =      bit.get enable1_flag 16
				
				local g_f4SpecularCol =bit.get enable2_flag  1
				local g_f4TileEffVal = bit.get enable2_flag  2
				local g_fAmbOccDif =   bit.get enable2_flag  3
				local g_fAmbOccLev =   bit.get enable2_flag  4
				local g_fBruiseLev =   bit.get enable2_flag  5
				local g_fHDRAlpha =    bit.get enable2_flag  6
				local g_fNoizeSpeed =  bit.get enable2_flag  7
				local g_fReflectAlpha =bit.get enable2_flag  8
				local g_fScrollU =     bit.get enable2_flag  9
				local g_fScrollU2 =    bit.get enable2_flag 10
				local g_fScrollU3 =    bit.get enable2_flag 11
				local g_fScrollU4 =    bit.get enable2_flag 12
				local g_fScrollV =     bit.get enable2_flag 13
				local g_fScrollV2 =    bit.get enable2_flag 14
				local g_fScrollV3 =    bit.get enable2_flag 15
				local g_fScrollV4 =    bit.get enable2_flag 16
				
				local g_fSL_Scale =    bit.get enable3_flag  1
				local g_fSpecularLev = bit.get enable3_flag  2
				local g_fSweatLev =    bit.get enable3_flag  3
				local g_fSweatSPA =    bit.get enable3_flag  4
				local g_fTileCountU =  bit.get enable3_flag  5
				local g_fTileCountV =  bit.get enable3_flag  6
				local g_fTileEffSw =   bit.get enable3_flag  7
				local g_fvLightLimit = bit.get enable3_flag  8
				local g_fWaveSpeed =   bit.get enable3_flag  9
				local g_fWrinkleBlend =bit.get enable3_flag 10
				local g_iBruiseParts = bit.get enable3_flag 11
				local g_iSpecularPow = bit.get enable3_flag 12
				local g_iWrinkleParts =bit.get enable3_flag 13
				
				local g_texDiffuse =   bit.get enable4_flag  1
				local texCubeRefction =bit.get enable4_flag  2
				local texDiffuse =     bit.get enable4_flag  3
				local texNoizeMap =    bit.get enable4_flag  4
				local texNormal =      bit.get enable4_flag  5
				local texOcclusion =   bit.get enable4_flag  6
				local texRefctionReg = bit.get enable4_flag  7
				local texSpecularMap = bit.get enable4_flag  8
				local texSphRefction = bit.get enable4_flag  9
				local texTilingMap =   bit.get enable4_flag 10
				local texUVScroll =    bit.get enable4_flag 11
				local texUVScroll2 =   bit.get enable4_flag 12
				local texUVScroll3 =   bit.get enable4_flag 13
				local texUVScroll4 =   bit.get enable4_flag 14
				local texWrinkleMap =  bit.get enable4_flag 15
				local texShimmer =     bit.get enable4_flag 16
				
				
				-----------------------------------------------------------------------
				-- Unknown Variables
				-----------------------------------------------------------------------
				if isProperty mat #unk14 do (unk14 = attr.unk14)
				if isProperty mat #unk15 do (unk15 = attr.unk15)
				if isProperty mat #unk16 do (unk16 = attr.unk16)
				
				name = "yBumpMap"
				if isProperty mat #type do (
					local rrxx_shaders = #(
						"",
						"yBumpMap",
						"yBumpMapSS",
						"yDefault",
						"yReflect",
						"ySilhouette",
						"yUVScroll",
						"yWater"
						)
					name = rrxx_shaders[attr.type]
					)
				
				-----------------------------------------------------------------------
				-- Colors
				-----------------------------------------------------------------------
				if (forceOn or g_f4MatAmbCol) and isProperty mat #g_f4MatAmbCol do (
					local c = attr.g_f4MatAmbCol
					append mat_params (Material_t type:"g_f4MatAmbCol" data:#((c.r/255.0), (c.g/255.0), (c.b/255.0), 1.0))
					)
				if (forceOn or g_f4MatDifCol) and isProperty mat #g_f4MatDifCol do (
					local c = attr.g_f4MatDifCol
					append mat_params (Material_t type:"g_f4MatDifCol" data:#((c.r/255.0), (c.g/255.0), (c.b/255.0), 1.0))
					)
				if (forceOn or g_f4SpecularCol) and isProperty mat #g_f4SpecularCol do (
					local c = attr.g_f4SpecularCol
					append mat_params (Material_t type:"g_f4SpecularCol" data:#((c.r/255.0), (c.g/255.0), (c.b/255.0), 1.0))
					)
				if (forceOn or g_f4BruiseCol) and isProperty mat #g_f4BruiseCol do (
					local c = attr.g_f4BruiseCol
					append mat_params (Material_t type:"g_f4BruiseCol" data:#((c.r/255.0), (c.g/255.0), (c.b/255.0), 1.0))
					)
				if (forceOn or g_f4FairyColorC) and isProperty mat #g_f4FairyColorC do (
					local c = attr.g_f4FairyColorC
					append mat_params (Material_t type:"g_f4FairyColorC" data:#((c.r/255.0), (c.g/255.0), (c.b/255.0), 1.0))
					)
				if (forceOn or g_f4FairyColorO) and isProperty mat #g_f4FairyColorO do (
					local c = attr.g_f4FairyColorO
					append mat_params (Material_t type:"g_f4FairyColorO" data:#((c.r/255.0), (c.g/255.0), (c.b/255.0), 1.0))
					)
				
				-----------------------------------------------------------------------
				-- Booleans
				-----------------------------------------------------------------------
				if (forceOn or g_bDiffTangent) and isProperty mat #g_bDiffTangent do (
					append mat_params (Material_t type:"g_bDiffTangent" data:#( if attr.g_bDiffTangent then 1 else 0 ))
					)
				if (forceOn or g_bDrawWrinkle) and isProperty mat #g_bDrawWrinkle do (
					append mat_params (Material_t type:"g_bDrawWrinkle" data:#( if attr.g_bDrawWrinkle then 1 else 0 ))
					)
				if (forceOn or g_bReflectAdd) and isProperty mat #g_bReflectAdd do (
					append mat_params (Material_t type:"g_bReflectAdd" data:#( if attr.g_bReflectAdd then 1 else 0 ))
					)
				if (forceOn or g_bUseGlow) and isProperty mat #g_bUseGlow do (
					append mat_params (Material_t type:"g_bUseGlow" data:#( if attr.g_bUseGlow then 1 else 0 ))
					)
				if (forceOn or g_bUseRefCube) and isProperty mat #g_bUseRefCube do (
					append mat_params (Material_t type:"g_bUseRefCube" data:#( if attr.g_bUseRefCube then 1 else 0 ))
					)
				if (forceOn or g_bUseRefRegMap) and isProperty mat #g_bUseRefRegMap do (
					append mat_params (Material_t type:"g_bUseRefRegMap" data:#( if attr.g_bUseRefRegMap then 1 else 0 ))
					)

				
				-----------------------------------------------------------------------
				-- The 4-float "g_f4Fairy" param
				-----------------------------------------------------------------------
				if ( (forceOn or g_f4Fairy) and isProperty mat #g_f4FairyX and (forceOn or THIS) and isProperty mat #g_f4FairyY and (forceOn or THIS) and isProperty mat #g_f4FairyZ and (forceOn or THIS) and isProperty mat #g_f4FairyW ) then (
					append mat_params (Material_t type:"g_f4Fairy" data:#( attr.g_f4FairyX, attr.g_f4FairyY, attr.g_f4FairyZ, attr.g_f4FairyW ))
					)

				-----------------------------------------------------------------------
				-- Single Floats
				-----------------------------------------------------------------------
				if (forceOn or g_fAmbOccDif) and isProperty mat #g_fAmbOccDif do (
					append mat_params (Material_t type:"g_fAmbOccDif" data:#( attr.g_fAmbOccDif ))
					)
				if (forceOn or g_fAmbOccLev) and isProperty mat #g_fAmbOccLev do (
					append mat_params (Material_t type:"g_fAmbOccLev" data:#( attr.g_fAmbOccLev ))
					)
				if (forceOn or g_fBruiseLev) and isProperty mat #g_fBruiseLev do (
					append mat_params (Material_t type:"g_fBruiseLev" data:#( attr.g_fBruiseLev ))
					)
				if (forceOn or g_fReflectAlpha) and isProperty mat #g_fReflectAlpha do (
					append mat_params (Material_t type:"g_fReflectAlpha" data:#( attr.g_fReflectAlpha ))
					)
				if (forceOn or g_fSweatLev) and isProperty mat #g_fSweatLev do (
					append mat_params (Material_t type:"g_fSweatLev" data:#( attr.g_fSweatLev ))
					)
				if (forceOn or g_fSweatSPA) and isProperty mat #g_fSweatSPA do (
					append mat_params (Material_t type:"g_fSweatSPA" data:#( attr.g_fSweatSPA ))
					)
				if (forceOn or g_fWrinkleBlend) and isProperty mat #g_fWrinkleBlend do (
					append mat_params (Material_t type:"g_fWrinkleBlend" data:#( attr.g_fWrinkleBlend ))
					)
				if (forceOn or g_fHDRAlpha) and isProperty mat #g_fHDRAlpha do (
					append mat_params (Material_t type:"g_fHDRAlpha" data:#( attr.g_fHDRAlpha ))
					)
				if (forceOn or g_fNoizeSpeed) and isProperty mat #g_fNoizeSpeed do (
					append mat_params (Material_t type:"g_fNoizeSpeed" data:#( attr.g_fNoizeSpeed ))
					)
				if (forceOn or g_fWaveSpeed) and isProperty mat #g_fWaveSpeed do (
					append mat_params (Material_t type:"g_fWaveSpeed" data:#( attr.g_fWaveSpeed ))
					)
				if (forceOn or g_fSpecularLev) and isProperty mat #g_fSpecularLev do (
					append mat_params (Material_t type:"g_fSpecularLev" data:#( attr.g_fSpecularLev ))
					)
				if (forceOn or g_fTileEffSw) and isProperty mat #g_fTileEffSw do (
					append mat_params (Material_t type:"g_fTileEffSw" data:#( attr.g_fTileEffSw ))
					)
				if (forceOn or g_fScrollU) and isProperty mat #g_fScrollU do (
					append mat_params (Material_t type:"g_fScrollU" data:#( attr.g_fScrollU ))
					)
				if (forceOn or g_fScrollV) and isProperty mat #g_fScrollV do (
					append mat_params (Material_t type:"g_fScrollV" data:#( attr.g_fScrollV ))
					)
				if (forceOn or g_fScrollU2) and isProperty mat #g_fScrollU2 do (
					append mat_params (Material_t type:"g_fScrollU2" data:#( attr.g_fScrollU2 ))
					)
				if (forceOn or g_fScrollV2) and isProperty mat #g_fScrollV2 do (
					append mat_params (Material_t type:"g_fScrollV2" data:#( attr.g_fScrollV2 ))
					)
				if (forceOn or g_fScrollU3) and isProperty mat #g_fScrollU3 do (
					append mat_params (Material_t type:"g_fScrollU3" data:#( attr.g_fScrollU3 ))
					)
				if (forceOn or g_fScrollV3) and isProperty mat #g_fScrollV3 do (
					append mat_params (Material_t type:"g_fScrollV3" data:#( attr.g_fScrollV3 ))
					)
				if (forceOn or g_fScrollU4) and isProperty mat #g_fScrollU4 do (
					append mat_params (Material_t type:"g_fScrollU4" data:#( attr.g_fScrollU4 ))
					)
				if (forceOn or g_fScrollV4) and isProperty mat #g_fScrollV4 do (
					append mat_params (Material_t type:"g_fScrollV4" data:#( attr.g_fScrollV4 ))
					)
				if (forceOn or g_fTileCountU) and isProperty mat #g_fTileCountU do (
					append mat_params (Material_t type:"g_fTileCountU" data:#( attr.g_fTileCountU ))
					)
				if (forceOn or g_fTileCountV) and isProperty mat #g_fTileCountV do (
					append mat_params (Material_t type:"g_fTileCountV" data:#( attr.g_fTileCountV ))
					)


				-----------------------------------------------------------------------
				-- "Vector" style floats, e.g. g_f2WrinkleRegU
				-----------------------------------------------------------------------
				if ( (forceOn or g_f2WrinkleRegU) and isProperty mat #g_f2WrinkleRegUx and (forceOn or THIS) and isProperty mat #g_f2WrinkleRegUy ) then (
					append mat_params (Material_t type:"g_f2WrinkleRegU" data:#(
						attr.g_f2WrinkleRegUx, 
						attr.g_f2WrinkleRegUy, 
						0.0, 0.0
						))
					)
				if ( (forceOn or g_f2WrinkleRegV) and isProperty mat #g_f2WrinkleRegVx and (forceOn or THIS) and isProperty mat #g_f2WrinkleRegVy ) then (
					append mat_params (Material_t type:"g_f2WrinkleRegV" data:#(
						attr.g_f2WrinkleRegVx, 
						attr.g_f2WrinkleRegVy, 
						0.0, 0.0
						))
					)
				-- 4-float vectors
				if ( (forceOn or g_f4TileEffVal) and isProperty mat #g_f4TileEffValX and (forceOn or THIS) and isProperty mat #g_f4TileEffValY and (forceOn or THIS) and isProperty mat #g_f4TileEffValZ and (forceOn or THIS) and isProperty mat #g_f4TileEffValW ) then	(
					append mat_params (Material_t type:"g_f4TileEffVal" data:#(
						attr.g_f4TileEffValX,
						attr.g_f4TileEffValY,
						attr.g_f4TileEffValZ,
						attr.g_f4TileEffValW
						))
					)
				if ( (forceOn or g_fvLightLimit) and isProperty mat #g_fvLightLimitX and (forceOn or THIS) and isProperty mat #g_fvLightLimitY and (forceOn or THIS) and isProperty mat #g_fvLightLimitZ and (forceOn or THIS) and isProperty mat #g_fvLightLimitW ) then	(
					append mat_params (Material_t type:"g_fvLightLimit" data:#(
						attr.g_fvLightLimitX,
						attr.g_fvLightLimitY,
						attr.g_fvLightLimitZ,
						attr.g_fvLightLimitW
						))
					)

				-----------------------------------------------------------------------
				-- Integers
				-----------------------------------------------------------------------
				if (forceOn or g_iBruiseParts) and isProperty mat #g_iBruiseParts do (
					append mat_params (Material_t type:"g_iBruiseParts" data:#( attr.g_iBruiseParts ))
					)
				if (forceOn or g_iSpecularPow) and isProperty mat #g_iSpecularPow do (
					append mat_params (Material_t type:"g_iSpecularPow" data:#( attr.g_iSpecularPow ))
					)
				if (forceOn or g_iWrinkleParts) and isProperty mat #g_iWrinkleParts do (
					append mat_params (Material_t type:"g_iWrinkleParts" data:#( attr.g_iWrinkleParts ))
					)
				
				-----------------------------------------------------------------------
				-- tex_names
				-----------------------------------------------------------------------
				if (forceOn or g_texDiffuse) and isProperty mat #g_texDiffuse do (
					local t = getFilenameFile (try(attr.g_texDiffuse.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"g_texDiffuse" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texCubeRefction) and isProperty mat #texCubeRefction do (
					local t = getFilenameFile (try(attr.texCubeRefction.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texCubeRefction" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texDiffuse) and isProperty mat #texDiffuse do (
					local t = getFilenameFile (try(attr.texDiffuse.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texDiffuse" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texNoizeMap) and isProperty mat #texNoizeMap do (
					local t = getFilenameFile (try(attr.texNoizeMap.filename)catch(""))
					local index = 0
					if t != "" then (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					else (
						local t = getFilenameFile (try(mat.diffuseMap.filename)catch(""))
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texNoizeMap" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texNormal) and isProperty mat #texNormal do (
					local t = getFilenameFile (try(attr.texNormal.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texNormal" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texOcclusion) and isProperty mat #texOcclusion do (
					local t = getFilenameFile (try(attr.texOcclusion.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texOcclusion" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texSpecularMap) and isProperty mat #texSpecularMap do (
					local t = getFilenameFile (try(attr.texSpecularMap.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texSpecularMap" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texSphRefction) and isProperty mat #texSphRefction do (
					local t = getFilenameFile (try(attr.texSphRefction.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texSphRefction" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texSpecularMap) and isProperty mat #texSpecularMap do (
					local t = getFilenameFile (try(attr.texSpecularMap.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texSpecularMap" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texTilingMap) and isProperty mat #texTilingMap do (
					local t = getFilenameFile (try(attr.texTilingMap.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texTilingMap" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texUVScroll) and isProperty mat #texUVScroll do (
					local t = getFilenameFile (try(attr.texUVScroll.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texUVScroll" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texUVScroll2) and isProperty mat #texUVScroll2 do (
					local t = getFilenameFile (try(attr.texUVScroll2.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texUVScroll2" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texUVScroll3) and isProperty mat #texUVScroll3 do (
					local t = getFilenameFile (try(attr.texUVScroll3.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texUVScroll3" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texUVScroll4) and isProperty mat #texUVScroll4 do (
					local t = getFilenameFile (try(attr.texUVScroll4.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texUVScroll4" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texWrinkleMap) and isProperty mat #texWrinkleMap do (
					local t = getFilenameFile (try(attr.texWrinkleMap.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texWrinkleMap" data:#(index - 1 + index_ofset))
					)
				if (forceOn or texShimmer) and isProperty mat #texShimmer do (
					local t = getFilenameFile (try(attr.texShimmer.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						)
					append mat_params (Material_t type:"texShimmer" data:#(index - 1 + index_ofset))
					)
				)
			else (
				
				
				if mat.diffuseMap != undefined do (
					local t = getFilenameFile (try(mat.diffuseMap.filename)catch(""))
					local index = 0
					if t != "" do (
						index = findItem tex_names t
						if index == 0 do (
							append tex_names t
							index = tex_names.count
							)
						append mat_params (Material_t type:"texDiffuse" data:#(index - 1 + index_ofset))
						)
					)
					
					
				
				)
			
			-- Return the array of Material_t structs:
			mat_params
			)
		)
	
	struct YokesObject_t (
		-- Header is 72 Bytes
		
		/*uint32*/  fileid         	 = 0x4A424F59, -- Size of the file 'YOBJ'
		/*uint32*/  filesize         = 0, -- Size of the file? also points to pof0 block, same as 'pof0_offset'
		/*uint32*/  reserve0         = 0, -- Always 0
		/*uint32*/  pof0_offset      = 0, -- Offset to data
		/*uint32*/  reserve1         = 0, -- Always 0
		/*uint32*/  reserve2         = 0, -- Always 0
		/*uint32*/  mesh_count       = 0, -- Material count
		/*uint32*/  mesh_offset      = 0, -- Offset to material data
		/*uint32*/  skel_count       = 0, -- Skeleton count
		/*uint32*/  texture_count  = 0, -- Texture name count
		/*uint32*/  skel_offset      = 0, -- Offset to skeleton data
		/*uint32*/  texture_offset = 0, -- Offset to texture names
		/*uint32*/  object_name_offset= 0, -- Offset to object names
		/*uint32*/  object_name_count = 0, -- Object name count
		/*uint32*/  reserve3         = 0, -- Always 0
		/*uint32*/  reserve4         = 0, -- Always 0
		/*uint32*/  reserve5         = 0, -- Always 0
		/*uint32*/  reserve6         = 0, -- Always 0
		
		-- Dynamic Data
		/*Mesh_t[]*/meshes           = #(),
		/*Bone_t[]*/bones            = #(),
		/*char[16][]*/textures     = #(),
		/*Object_t[]*/object_names    = #(),
		/*PointerOffsets_t*/ pof0    = PointerOffsets_t(),
		
		
		fn printInfo = (
			format "fileid: \t0x%\n" (bit.IntAsHex fileid)
			format "filesize: \t%\n" filesize
			format "reserve0: \t%\n" reserve0
			format "pof0_offset: \t%\n" ((pof0_offset + 8) as integer)
			format "reserve1: \t%\n" reserve1
			format "reserve2: \t%\n" reserve2
			format "mesh_count: \t%\n" mesh_count
			format "mesh_offset: \t%\n" ((mesh_offset + 8) as integer)
			format "skel_count: \t%\n" skel_count
			format "texture_count: \t%\n" texture_count
			format "skel_offset: \t%\n" ((skel_offset + 8) as integer)
			format "texture_offset: \t%\n" ((texture_offset + 8) as integer)
			format "object_name_offset: \t%\n" ((object_name_offset + 8) as integer)
			format "object_name_count: \t%\n" object_name_count
			format "reserve3: \t%\n" reserve3
			format "reserve4: \t%\n" reserve4
			format "reserve5: \t%\n" reserve5
			format "reserve6: \t%\n" reserve6
			),
		
		fn update_pointers = (
			
			local ptr = 64
			local SIZE_OF_INT = 4
			local SIZE_OF_SHORT = 2
			local SIZE_OF_VERTEX = 28
			local SIZE_OF_MESH = 180
			local SIZE_OF_FACE_INFO = 12
			local SIZE_OF_BONE = 80
			local SIZE_OF_NAME = 16
			local SIZE_OF_NODE = 32
			
			mesh_count = meshes.count
			mesh_offset = 0
			if mesh_count > 0 do (
				
				mesh_offset = ptr
				ptr += mesh_count * SIZE_OF_MESH
				
				for m in meshes do (
					m.mat_param_count = m.mat_params.count
					m.mat_param_offset = ptr
					
					ptr += m.mat_param_count * SIZE_OF_INT
					for p = 1 to m.mat_param_count do (
						m.mat_param_addrs[p] = ptr
						ptr += m.mat_params[p].size()
						)
					
					m.vertex_count = m.vertices.count
					m.texcoord_count = m.vertex_count
					
					m.vertex_buf_offset = ptr
					ptr += SIZE_OF_INT
					
					m.vertex_offset = ptr
					ptr += m.vertex_count * SIZE_OF_VERTEX
					
					m.weight_offset = ptr
					ptr += m.vertex_count * m.num_bone_weights * SIZE_OF_INT * 2
					
					m.texcoord_offset = ptr
					ptr += m.vertex_count * SIZE_OF_INT * 2
					
					m.element_offset = ptr
					m.element_count = m.elements.count
					ptr += m.element_count * SIZE_OF_FACE_INFO
					
					for f = 1 to m.element_count do (
						m.elements[f].face_count = m.elements[f].faces.count
						m.elements[f].face_offset = ptr
						ptr += m.elements[f].face_count * SIZE_OF_SHORT
						if bit.and m.elements[f].face_count 1 == 1 do (
							ptr += SIZE_OF_SHORT
							)
						)
					)
				)
			
			skel_count = bones.count
			skel_offset = 0
			if skel_count > 0 do (
				skel_offset = ptr
				ptr += skel_count * SIZE_OF_BONE
				)
			
			texture_count = textures.count
			texture_offset = 0
			if texture_count > 0 do (
				texture_offset = ptr
				ptr += texture_count * SIZE_OF_NAME
				)
			
			object_name_count = object_names.count
			object_name_offset = 0
			if object_name_count > 0 do (
				object_name_offset = ptr
				ptr += object_name_count * SIZE_OF_NODE
				)
			
			filesize = ptr
			pof0_offset = ptr
			
			pof0.offsets = #(
				20,  -- distance from start to mesh_offset
				12,  -- distance from mesh_offset to skel_offset
				4,   -- distance from skel_offset to texture_offset
				4,    -- distance from texture_offset to object_name_offset
				24     -- Align to the end of the header
				)
			
			if mesh_count > 0 do (
				
				-- Add relative jumps for each pointer in mesh block
				for i = 1 to mesh_count do (
					
					-- Update last offset, to algn to the next pointer, vertex_offset
					pof0.offsets[pof0.offsets.count] += 104
					
					append pof0.offsets 4   -- distance from vertex_buf_offset to weight_offset
					append pof0.offsets 4   -- distance from weight_offset to texcoord_offset
					append pof0.offsets 36  -- distance from texcoord_offset to mat_param_offset
					append pof0.offsets 4   -- distance from mat_param_offset to element_offset
					append pof0.offsets 28  -- align to the end of the mesh block
					)
				for m in meshes do (
					-- Add relative jumps for the mat_param_offset's
					
					for i = 1 to m.mat_param_count do (
						append pof0.offsets 4
						)
					-- Align
					pof0.offsets[pof0.offsets.count] = 0
					for i = 1 to m.mat_param_count do (
						pof0.offsets[pof0.offsets.count] += m.mat_params[i].size()
						)
					
					if m.vertex_count > 0 do (
						-- Update last offset
						pof0.offsets[pof0.offsets.count] += 4
						
						-- Align to the end of the vertices
						append pof0.offsets ((m.vertex_count * SIZE_OF_VERTEX) + (m.vertex_count * m.num_bone_weights * SIZE_OF_INT * 2) + (m.vertex_count * SIZE_OF_INT * 2))
						
						)
					if m.element_count > 0 do (
						
						-- Update last offset to move to the first element address
						pof0.offsets[pof0.offsets.count] += 12
						
						for f = 1 to m.element_count do (
							append pof0.offsets SIZE_OF_FACE_INFO
							)
						
						-- Align the end of the faces
						pof0.offsets[pof0.offsets.count] = 4
						for f = 1 to m.element_count do (
							local SIZE_OF_FACE_ELEMENT = m.elements[f].face_count * SIZE_OF_SHORT
							pof0.offsets[pof0.offsets.count] += SIZE_OF_FACE_ELEMENT
							pof0.offsets[pof0.offsets.count] += mod (SIZE_OF_INT-(mod SIZE_OF_FACE_ELEMENT SIZE_OF_INT)) SIZE_OF_INT
							)
						)
					)
				deleteItem pof0.offsets pof0.offsets.count
				)
			),
		
		fn colorBones &boneArray = (
			
			-- Define color palette
			local colorHead = color 166 202 240
			local colorSpine = color 8 110 134
			local colorLeft = color 28 28 177
			local colorRight = color 6 134 6
			local colorRoot = color 115 115 115
			local colorPelvis = color 224 198 87
			local colorLeftThumb = color 134 6 6
			local colorRightThumb = color 224 198 87
			local colorLeftFingers = color 108 8 136
			local colorRightFingers = color 113 134 6
			
			-- Iterate through each bone
			for b in boneArray do (
				local hasParent = (b.parent != undefined)
				local isRoot = (not hasParent or matchPattern b.name pattern:"root")
				local isHead = matchPattern b.name pattern:"*head*" or matchPattern b.name pattern:"atama*"
				local isSpine = matchPattern b.name pattern:"*spine*" or matchPattern b.name pattern:"mune*"
				local isPelvis = matchPattern b.name pattern:"*pelvis*" or matchPattern b.name pattern:"koshi"
				local isLeg = matchPattern b.name pattern:"*leg*" or matchPattern b.name pattern:"*momo*" or matchPattern b.name pattern:"*sune*" or matchPattern b.name pattern:"*ashi*" or matchPattern b.name pattern:"*shin*" or matchPattern b.name pattern:"*calf*"
				local isArm = matchPattern b.name pattern:"*arm*" or matchPattern b.name pattern:"*ninoude*" or matchPattern b.name pattern:"*kote*" or matchPattern b.name pattern:"*wrist*" or matchPattern b.name pattern:"*shoulder*"
				local isFinger = matchPattern b.name pattern:"*finger*" or matchPattern b.name pattern:"*yubi*"
				local isThumb = matchPattern b.name pattern:"*thumb*"
				local isLeftBone = matchPattern b.name pattern:"l_*" or matchPattern b.name pattern:"kl_*"
				local isRightBone = matchPattern b.name pattern:"r_*" or matchPattern b.name pattern:"kr_*"
				
				-- Assign colors based on positions, names, and relationships
				if isRoot then (
					b.wirecolor = colorRoot
					)
				else if isHead then (
					b.wirecolor = colorHead
					)
				else if isSpine then (
					b.wirecolor = colorSpine
					)
				else if isPelvis then (
					b.wirecolor = colorPelvis
					)
				else if isLeg then (
					if isLeftBone then (
						b.wirecolor = colorLeft
						) else if isRightBone then (
						b.wirecolor = colorRight
						)
					)
				else if isArm then (
					if isLeftBone then (
						b.wirecolor = colorLeft
						) else if isRightBone then (
						b.wirecolor = colorRight
						)
					)
				else if isFinger then (
					if isLeftBone then (
						b.wirecolor = colorLeftFingers
						) else if isRightBone then (
						b.wirecolor = colorRightFingers
						)
					)
				
				-- Always propagate color to children
				for child in b.children do (
					child.wirecolor = b.wirecolor
					)
				)
			--format "Bone coloring complete!\n"
			),
		

		
		fn import mscale:(1.0 / 0.254) rotateUp:true matDeepMerge:false impColors:false impWeights:true impNormals:false impMesh:true clearScene:true = (
			
			if clearScene do delete objects
			max modify mode
			
			
			local num_bones = bones.count
			if num_bones > 0 do (
				local boneArray = #()
				local transArray = #()
				local found_bones = #{1..(num_bones)}
				
				boneArray[num_bones] = undefined
				transArray[num_bones] = matrix3 1
				
				-- Create Bones
				for i = 1 to num_bones do (
					
					local bone_pos = [bones[i].bone_position[1], bones[i].bone_position[3], -bones[i].bone_position[2]] * mscale
					transArray[i] = (eulerangles (radtodeg (-bones[i].bone_rotation[1])) (radtodeg (bones[i].bone_rotation[3])) (radtodeg (-bones[i].bone_rotation[2]))) as matrix3
					transArray[i].row4 = bone_pos
					
					local d = getNodeByName bones[i].bone_name
					
					if d == undefined then (
						
						d = bonesys.createbone bone_pos (bone_pos+[0,0,1]) [0,1,0]
						d.name = bones[i].bone_name
						d.transform = transArray[i]
						d.showLinks = d.showLinksOnly = true
						) else (found_bones[i] = false)
					
					boneArray[i] = d
					)
				
				for i = 1 to num_bones do (
					if bones[i].bone_parent > -1 then (
						transArray[i] *= transArray[bones[i].bone_parent + 1]
						)
					else if rotateUp then (
						--transArray[i] *= rotateXMatrix 270
						)
					)
				
				for i = 1 to num_bones do (
					
					if found_bones[i] do (
						boneArray[i].transform = transArray[i]
						)
					
					if bones[i].bone_parent > -1 do (
						boneArray[i].parent = boneArray[bones[i].bone_parent + 1]
						)
					)
				
				for i = 1 to num_bones do (
					if bones[i].atari.diameter > 0.0001 and bones[i].atari.diameter < 100000.0 do ( -- wrong endian
						local bone_pos = bones[i].atari.position * mscale
						local bone_rad = (bones[i].atari.diameter / 2.0) * mscale
						local b = sphere position:bone_pos segs:10 radius:bone_rad name:("at_" + bones[i].bone_name)
						if rotateUp do b.transform *= rotateXMatrix 270
						b.renderable = off
						b.backfacecull = on
						b.xray = on
						b.parent = boneArray[i]
						freeze b
						hide b
						)
					)
				
				colorBones &boneArray
				)
			
			
			local num_submeshes = meshes.count
			if impMesh and num_submeshes > 0 do (
				-- Build the meshes
				local unique_materials = #()
				local lookup_materials = #()
				local temp_materials = #()
				
				templateMaterial = StandardMaterial name:"RumbleRosesXxMaterial"
				attachShaderAttributesToMaterial templateMaterial
				ambientColor = color 80 80 80
				lightLevel = 1.0
				
				for m in meshes do (
					local mat_str = ""
					
					if matDeepMerge then (
						local mat_arr = #()
						for p in m.mat_params do (
							if p.entry_type == 0x0F and p.data[1] == -1 do continue
							append mat_arr (p.type + (p.data as string))
							)
						sort mat_arr
						for s in mat_arr do (
							mat_str += s
							)
						)
					else (
						for p in m.mat_params do (
							mat_str += p.type + (p.data as string)
							)
						)
					
					local index = findItem temp_materials mat_str
					if index == 0 do (
						append temp_materials mat_str
						append unique_materials p
						index = temp_materials.count
						)
					append lookup_materials index
					)
				local num_materials = temp_materials.count
				temp_materials = undefined
				
				if num_submeshes > 0 do (
					
					-- They defined a set of sub meshes, they provide
					-- and index that tell us what mesh object they are a part of
					-- collect group ids
					
					local mat = MultiMaterial numsubs:num_materials
					local built_mats = #{1..(num_materials)}
					
					-- Collect all unique ids
					local group_ids = #()
					for i = 1 to num_submeshes do (
						local index = findItem group_ids meshes[i].group_index
						if index == 0 do (
							append group_ids meshes[i].group_index
							)
						)
					local num_objects = group_ids.count
					sort group_ids
					
					-- build each object
					local built_objs = #{1..(num_submeshes)}
					local texture_offset = 1
					local rrxx_shaders = #(
						"", "yBumpMap", "yBumpMapSS", "yDefault", "yReflect", "ySilhouette", "yUVScroll", "yWater"
						)
					for o = 1 to num_objects do (
						
-- 						local texture_lookup = #()
-- 						for j = texture_offset to object_names[o].num_textures do (
-- 							append texture_lookup textures[j]
-- 							)
-- 						texture_offset += object_names[o].num_textures
						
						-- Setup Arrays
						local vertArray = #()
						local tvertArray = #()
						local normArray = #()
						local cvertArray = #()
						local faceArray = #()
						local matIDArray = #()
						local weightArray = #()
						local boneidArray = #()
						local bonePal = #()
						
						-- Check what meshes match the current object
						local vert_pos = 1
						for i in built_objs do (
							
							local matid = lookup_materials[i]
							
							if built_mats[matid] do (
								
								--mat[matid] = StandardMaterial()
								mat[matid] = copy templateMaterial
								if custAttributes.count mat[matid] > 0 do (
									
									mat[matid].diffuse = random white black
									
									mat[matid].specularLevel = random 20 100
									mat[matid].glossiness = random 0 20
									
									local shaderAttr = custAttributes.get mat[matid] 1
									
									local shader_index = findItem rrxx_shaders meshes[i].name
									if shader_index > 1 do (
										shaderAttr.type = shader_index
										)
									shaderAttr.unk14 = meshes[i].unk14
									shaderAttr.unk15 = meshes[i].unk15
									shaderAttr.unk16 = meshes[i].unk16
									
									--print ("Copied Material Shader Name: " + (shaderAttr.type as string))
									
									local mat_name = ""
									local enable1_flag = 0
									local enable2_flag = 0
									local enable3_flag = 0
									local enable4_flag = 0
									for m in meshes[i].mat_params do (
										
										m.setMaxMaterialFlags &enable1_flag &enable2_flag &enable3_flag &enable4_flag
										
										-- We switch on the 'type' string of each Material_t struct
										case m.type of (
											/* -------------------------------------------------------------
											   Booleans
											   ------------------------------------------------------------- */
											"g_bDiffTangent":  ( mat[matid].g_bDiffTangent  = (m.data[1] > 0) )
											"g_bDrawWrinkle":  ( mat[matid].g_bDrawWrinkle  = (m.data[1] > 0) )
											"g_bReflectAdd":   ( mat[matid].g_bReflectAdd   = (m.data[1] > 0) )
											"g_bUseGlow":      ( mat[matid].g_bUseGlow      = (m.data[1] > 0) )
											"g_bUseRefCube":   ( mat[matid].g_bUseRefCube   = (m.data[1] > 0) )
											"g_bUseRefRegMap": ( mat[matid].g_bUseRefRegMap = (m.data[1] > 0) )
											
											/* -------------------------------------------------------------
											   Colors (4 floats typically storing RGBA)
											   We also set the standard (max) material colors for Amb/Dif/Spec
											   as convenient.  If you have alpha, you can store it in a spare
											   float param or ignore it.
											   ------------------------------------------------------------- */
											"g_f4MatAmbCol": (
												local c = color (m.data[1] * 255) (m.data[2] * 255) (m.data[3] * 255)
												mat[matid].g_f4MatAmbCol = c
												mat[matid].ambient       = c  -- so the standard material matches
												)
											"g_f4MatDifCol": (
												local c = color (m.data[1] * 255) (m.data[2] * 255) (m.data[3] * 255)
												mat[matid].g_f4MatDifCol = c
												mat[matid].diffuse       = c  -- so the standard material matches
												)
											"g_f4SpecularCol": (
												local c = color (m.data[1] * 255) (m.data[2] * 255) (m.data[3] * 255)
												mat[matid].g_f4SpecularCol = c
												mat[matid].specular        = c -- so the standard material matches
												)
											"g_f4BruiseCol": (
												local c = color (m.data[1] * 255) (m.data[2] * 255) (m.data[3] * 255)
												mat[matid].g_f4BruiseCol = c
												)
											"g_f4Fairy": ( -- If you prefer to store in 3 or 4 separate floats, that works too
												-- Example: store R/G/B in g_f4FairyX/Y/Z
												mat[matid].g_f4FairyX = m.data[1]
												mat[matid].g_f4FairyY = m.data[2]
												mat[matid].g_f4FairyZ = m.data[3]
												mat[matid].g_f4FairyW = m.data[4]
												)
											"g_f4FairyColorC": (
												local c = color (m.data[1] * 255) (m.data[2] * 255) (m.data[3] * 255)
												mat[matid].g_f4FairyColorC = c
												)
											"g_f4FairyColorO": (
												local c = color (m.data[1] * 255) (m.data[2] * 255) (m.data[3] * 255)
												mat[matid].g_f4FairyColorO = c
												)
											/* -------------------------------------------------------------
											   Single Floats
											   ------------------------------------------------------------- */
											"g_fAmbOccDif":    ( mat[matid].g_fAmbOccDif    = m.data[1] )
											"g_fAmbOccLev":    ( mat[matid].g_fAmbOccLev    = m.data[1] )
											"g_fBruiseLev":    ( mat[matid].g_fBruiseLev    = m.data[1] )
											"g_fReflectAlpha": ( mat[matid].g_fReflectAlpha = m.data[1] )
											"g_fSweatLev":     ( mat[matid].g_fSweatLev     = m.data[1] )
											"g_fSweatSPA":     ( mat[matid].g_fSweatSPA     = m.data[1] )
											"g_fWrinkleBlend": ( mat[matid].g_fWrinkleBlend = m.data[1] )
											"g_fHDRAlpha":     ( mat[matid].g_fHDRAlpha     = m.data[1] )
											"g_fNoizeSpeed":   ( mat[matid].g_fNoizeSpeed   = m.data[1] )
											"g_fWaveSpeed":    ( mat[matid].g_fWaveSpeed    = m.data[1] )
											"g_fSpecularLev":  ( mat[matid].g_fSpecularLev  = m.data[1] )
											--"g_fSL_Scale":     ( mat[matid].g_fSL_Scale     = m.data[1] )
											-- etc. for the single-float parameters

											/* -------------------------------------------------------------
											   "Vector" of floats used for e.g. scrolling or 4-vector
											   ------------------------------------------------------------- */
											"g_f2WrinkleRegU": (
												-- Sometimes these come as #(u, v, 0, 0); you may only need 2
												mat[matid].g_f2WrinkleRegUx = m.data[1]
												mat[matid].g_f2WrinkleRegUy = m.data[2]
												)
											"g_f2WrinkleRegV": (
												mat[matid].g_f2WrinkleRegVx = m.data[1]
												mat[matid].g_f2WrinkleRegVy = m.data[2]
												)
											"g_f4TileEffVal": (
												mat[matid].g_f4TileEffValX = m.data[1]
												mat[matid].g_f4TileEffValY = m.data[2]
												mat[matid].g_f4TileEffValZ = m.data[3]
												mat[matid].g_f4TileEffValW = m.data[4]
												)
											"g_fvLightLimit": (
												mat[matid].g_fvLightLimitX = m.data[1]
												mat[matid].g_fvLightLimitY = m.data[2]
												mat[matid].g_fvLightLimitZ = m.data[3]
												mat[matid].g_fvLightLimitW = m.data[4]
												)
											/* -------------------------------------------------------------
											   Scrolling offsets (U/V). 
											   Sometimes you only get one float e.g. g_fScrollU => m.data[1]
											   If you have g_fScrollU2, etc. do the same logic.
											   ------------------------------------------------------------- */
											"g_fScrollU":  ( mat[matid].g_fScrollU  = m.data[1] )
											"g_fScrollV":  ( mat[matid].g_fScrollV  = m.data[1] )
											"g_fScrollU2": ( mat[matid].g_fScrollU2 = m.data[1] )
											"g_fScrollV2": ( mat[matid].g_fScrollV2 = m.data[1] )
											"g_fScrollU3": ( mat[matid].g_fScrollU3 = m.data[1] )
											"g_fScrollV3": ( mat[matid].g_fScrollV3 = m.data[1] )
											"g_fScrollU4": ( mat[matid].g_fScrollU4 = m.data[1] )
											"g_fScrollV4": ( mat[matid].g_fScrollV4 = m.data[1] )

											"g_fTileCountU": ( mat[matid].g_fTileCountU = m.data[1] )
											"g_fTileCountV": ( mat[matid].g_fTileCountV = m.data[1] )
											"g_fTileEffSw":  ( mat[matid].g_fTileEffSw  = m.data[1] )

											/* -------------------------------------------------------------
											   Integers
											   ------------------------------------------------------------- */
											"g_iBruiseParts":  ( mat[matid].g_iBruiseParts  = m.data[1] )
											"g_iSpecularPow":  ( mat[matid].g_iSpecularPow  = m.data[1] )
											"g_iWrinkleParts": ( mat[matid].g_iWrinkleParts = m.data[1] )

											/* -------------------------------------------------------------
											   Textures:  if m.data[1] != -1, you have a real texture index.
											   The 'textures' array presumably has the filename.  Create a 
											   bitmapTexture if you want to load it automatically into 3ds Max
											   ------------------------------------------------------------- */
											"g_texDiffuse": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].g_texDiffuse = Bitmaptexture filename:texName
													mat[matid].diffuseMap = Bitmaptexture filename:texName
													mat_name = textures[m.data[1]+1]
													)
												)
											"texDiffuse": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texDiffuse = Bitmaptexture filename:texName
													mat[matid].diffuseMap = Bitmaptexture filename:texName
													mat_name = textures[m.data[1]+1]
													)
												)
											"texNormal": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texNormal = Bitmaptexture filename:texName
													)
												)
											"texSphRefction": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texSphRefction = Bitmaptexture filename:texName
													)
												)
											"texCubeRefction": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texCubeRefction = Bitmaptexture filename:texName
													)
												)
											"texRefctionReg": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texRefctionReg = Bitmaptexture filename:texName
													)
												)
											"texSpecularMap": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texSpecularMap = Bitmaptexture filename:texName
													mat[matid].SpecularMap = Bitmaptexture filename:texName
													)
												)
											"texWrinkleMap": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texWrinkleMap = Bitmaptexture filename:texName
													)
												)
											"texShimmer": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texShimmer = Bitmaptexture filename:texName
													)
												)
											"texTilingMap": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texTilingMap = Bitmaptexture filename:texName
													)
												)
											"texNoizeMap": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texNoizeMap = Bitmaptexture filename:texName
													)
												)
											"texUVScroll": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texUVScroll = Bitmaptexture filename:texName
													)
												)
											"texUVScroll2": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texUVScroll2 = Bitmaptexture filename:texName
													)
												)
											"texUVScroll3": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texUVScroll3 = Bitmaptexture filename:texName
													)
												)
											"texUVScroll4": (
												if m.data[1] != -1 do (
													local texName = textures[m.data[1]+1] + ".dds"
													mat[matid].texUVScroll4 = Bitmaptexture filename:texName
													)
												)
											
											-- If you have any other custom param types left, handle them here
											default: (
												-- For unrecognized param types: do nothing or print a debug msg
												format "Unhandled param type: %\n" m.type
-- Unhandled param type: g_f4FairyLv
-- Unhandled param type: g_f4Scale
-- Unhandled param type: g_fSL_Scale
-- Unhandled param type: texOcclusion
												)
											)
										)
									
									-- store a state of what params were found in the material
									shaderAttr.enable1 = enable1_flag
									shaderAttr.enable2 = enable2_flag
									shaderAttr.enable3 = enable3_flag
									shaderAttr.enable4 = enable4_flag
									
									if mat_name != "" do (
										mat[matid].name = mat_name
										local last_chr = 0
										for c = 1 to mat_name.count do (
											local b = bit.charAsInt (subString mat_name c 1)
											if b >= 48 and b <= 57 do (
												last_chr = c
												)
											)
										if last_chr > 0 do (
											mat.names[matid] = subString mat_name (last_chr + 1) -1
											)
										)
									)
								built_mats[matid] = false
								)
							
							
							-- if mesh belongs to current object, build it
							if group_ids[o] == meshes[i].group_index and meshes[i].element_count > 0 do (
								
								
								if rotateUp then (
									for vert in meshes[i].vertices do (
										
										append vertArray ([vert.position[1], vert.position[3], -vert.position[2]] * mscale)
										append cvertArray vert.colour
										append normArray [-vert.normal[1], -vert.normal[3], vert.normal[2]]
										
										)
									)
								else (
									for vert in meshes[i].vertices do (
										
										append vertArray (vert.position * mscale)
										append cvertArray vert.colour
										append normArray vert.normal
										)
									)
								
								for j = 1 to meshes[i].texcoords.count do (
									append tvertArray [meshes[i].texcoords[j][1], 1.0-meshes[i].texcoords[j][2], 0.0]
									
									)
								
								if impWeights do (
									for w in meshes[i].bone_weights do (
										append weightArray w
										)
									for boneids in meshes[i].bone_ids do (
										local tmp = #()
										for b in boneids do (
											local bone_index = -1
											if b != 255 do (
												bone_index = meshes[i].bone_map[b + 1]
												if bone_index > -1 and findItem bonePal bone_index == 0 do (
													append bonePal bone_index
													)
												)
											
											append tmp bone_index
											)
										append boneidArray tmp
										)
									)
								
								
								for face in meshes[i].elements do (
									
									face.asTriangles 0 face.face_count &faceArray &matIDArray face_add:vert_pos vertex_start:0 matid:matid
									
									
									
									
									)
								vert_pos += meshes[i].vertex_count
								
								i = false
								)
								
							
							)
						
						local msh = mesh vertices:vertArray tverts:tvertArray faces:faceArray materialIds:matIDArray
						buildTVFaces msh
						local obj_index = group_ids[o] + 1
						
						if obj_index <= object_names.count do (
							msh.name = object_names[obj_index].name
							)
						msh.material = mat
						msh.backfacecull = on
						msh.displayByLayer = false
						msh.wirecolor = random (color 0 0 0) (color 255 255 255)
						
						for i = 1 to faceArray.count do (setTVFace msh i faceArray[i])
						for i = 1 to msh.numfaces do setFaceSmoothGroup msh i 1
						
						update msh
						select msh
						
						
						
						if impNormals do (
							local normMod = Edit_Normals()
							addmodifier msh normMod ui:off
							select msh
							modPanel.setCurrentObject normMod
							normMod.selectBy = 1
							normMod.displayLength = 0.64516 * mscale
							normMod.MakeExplicit selection:#{1..(normArray.count)}
							local normID = #{}
							--apply normals
							for i = 1 to normArray.count do (
								normID = #{} --free normID
								normMod.ConvertVertexSelection #{i} &normID
								for ii in normID do (
									normMod.SetNormal ii (normalize normArray[i])
									)
								)
							--collapseStack msh
							subobjectLevel = 0
							)
						
						if impColors do (
							local num_cverts = cvertArray.count
							setNumCPVVerts msh num_cverts
							defaultVCFaces msh
							meshop.setVertAlpha msh -2 #(1, num_cverts) 0.0
							for i = 1 to num_cverts do (setVertColor msh i (color (cvertArray[i][1] * 255) (cvertArray[i][2] * 255) (cvertArray[i][3] * 255)))
							for i = 1 to num_cverts do (meshop.setMapVert msh -2 i ([0.0, 0.0, 0.0] + cvertArray[i][4]))
							local vcolMod = VertexPaint()
							addmodifier msh vcolMod ui:off
							)
						
						if impWeights and boneArray.count > 0 do (
							
							-- apply a skin modifier
							local skinMod = skin()
							addModifier msh skinMod ui:off
							select msh
							
							-- assign bones to skin modifier, from the weight pallete
							for i = 1 to bonePal.count do (
								
								skinOps.addbone skinMod boneArray[bonePal[i]]  (
									if i == bonePal.count then 1 else 0
									)
								)
							
							
							-- get names of bones in skin list
							local bneTmp = #()
							bneTmp[bonePal.count] = ""
							for i = 1 to bonePal.count do (
								bneTmp[i] = skinOps.GetBoneName skinMod i 0
								)
							-- create a bonemap
							local boneMap = #()
							boneMap[boneArray.count] = 1
							for i = 1 to boneArray.count do (
								boneMap[i] = 1 -- default assignment to first bone in skin list
								local bone_index = findItem bneTmp boneArray[i].name
								if bone_index > 0 do (boneMap[i] = bone_index)
								)
							
							
							-- apply weights to skin modifier
							modPanel.setCurrentObject skinMod
							for i = 1 to weightArray.count do (
								local numBones = weightArray[i].count
								local bi = #()
								local bw = #()
								if numBones > 0 do (
									for ii = 1 to numBones do (
										local bone_index = boneidArray[i][ii]
										if bone_index > -1 and weightArray[i][ii] > 0.00001 do (
											bone_index = boneMap[bone_index]
											append bi bone_index
											append bw weightArray[i][ii]
											)
										
										)
									skinOps.ReplaceVertexWeights skinMod i bi bw
									)
								)
							
							if skinOps.isWeightToolOpen skinMod == 0 do (
								skinOps.WeightTool skinMod
								)
							skinMod.filter_vertices = on
							)
						
						
						)
					)
				)
			
-- 			-- Store the textures to lookup
-- 			local propName = "RRxxTextureList"  -- name of the property key
-- 			
-- 			-- Delete Existing Key
-- 			local existingIndex = fileProperties.findProperty #custom propName
-- 			if existingIndex != 0 do (fileProperties.deleteProperty #custom propName)
-- 			
-- 			-- Create A New Key
-- 			local combinedString = ""
-- 			for t in textures do (combinedString += t + ";")
-- 			fileProperties.addProperty #custom propName combinedString
			),
		
		fn export selectionOnly:false outFile:"" mscale:0.254 maxInfluences:4 impColors:false impWeights:true optimizeVerts:true rotateUp:true maxBoneMap:17 maxFaceIndex:0x3fff = (
			
			local allTextures = #()
			textures = #()
			-- preserve old textures
			--allTextures = copy textures #nomap -- ok order doesnt matter?
			
-- 			local propName = "RRxxTextureList"  -- name of the property key
-- 			propIndex = fileProperties.findProperty #custom propName
-- 			if propIndex != 0 do (
-- 				local retrievedString = fileProperties.getPropertyValue #custom propIndex
-- 				if retrievedString != undefined do (
-- 					allTextures = filterString retrievedString ";"
-- 					print allTextures
-- 					)
-- 				)
-- 			
			setCommandPanelTaskMode #modify
			-------------------------------------------
			-- Create local placeholders (like YokesObject_t)
			-------------------------------------------
			local fileid = 0x4A424F59 
			local filesize = 0 
			local mesh_count = 0
			local mesh_offset = 0
			local skel_count = 0
			local skel_offset = 0
			local texture_count = 0
			local texture_offset = 0
			local object_name_count = 0
			local object_name_offset = 0
			
			-------------------------------------------
			-- 1) Gather bones
			-------------------------------------------
			local sceneBones = for o in objects where (findItem (#(BoneGeometry)) (classOf o)) > 0 collect o
			
			bones = #()
			local boneNames = #() 
			for b in sceneBones do (
				local bStruct = Bone_t()
				bStruct.bone_name = b.name
				
				local parent = b.parent
				local parentIndex = -1
				if (parent != undefined and findItem sceneBones parent > 0) do (
					parentIndex = findItem sceneBones parent - 1
					)
				bStruct.bone_parent = parentIndex

				local localTM = b.transform
				if parentIndex >= 0 then (
					local parentTM = sceneBones[parentIndex+1].transform
					localTM = b.transform * inverse parentTM
					)
				else (
					--localTM = b.transform * inverse (rotateXMatrix 270)
					
					)

				local pos = localTM.pos
				local rotEuler = quatToEuler2 (localTM)   -- returns EulerAngles in degrees
				bStruct.bone_position = #( pos.x * mscale, -pos.z * mscale, pos.y * mscale, 0.0 )
				bStruct.bone_rotation = #( -(DegToRad rotEuler.x), -(DegToRad rotEuler.z), DegToRad rotEuler.y, 0.0 )
				
				
				local foundSphere = undefined
				for childObj in b.children where (childObj != undefined and classof childObj == Sphere) do (
					foundSphere = childObj
					exit
					)
				if foundSphere != undefined then (
					bStruct.atari.position = #(
						foundSphere.position.x * mscale,
						foundSphere.position.y * mscale,
						foundSphere.position.z * mscale
						)
					bStruct.atari.diameter = (foundSphere.radius * 2.0) * mscale
					)
				else (
					bStruct.atari.position = #(0.0, 0.0, 0.0)
					bStruct.atari.diameter = 0.0
					)
				append boneNames b.name
				append bones bStruct
				)
			if bones.count == 0 do bones = #(Bone_t name:"Root")
			skel_count = bones.count
			
			-------------------------------------------
			-- 2) Gather geometry
			-------------------------------------------
			local meshObjs = #()
			object_names = #()
			if selectionOnly then
				meshObjs = for o in selection where (findItem (#(Editable_mesh, Editable_Poly, PolyMeshObject)) (classOf o)) > 0 collect o
			else
				meshObjs = for o in objects where (findItem (#(Editable_mesh, Editable_Poly, PolyMeshObject)) (classOf o)) > 0 collect o
			
			meshes = #()  -- final array of Mesh_t
			
			
			for o = 1 to meshObjs.count do (
				local localTextures = #()
				local obj = meshObjs[o]
				local tmesh = snapshotAsMesh obj
				if tmesh.numfaces < 1 then (
					delete tmesh
					continue
					)
				
				-------------------------------------------
				-- (a) Record object name
				-------------------------------------------
				append object_names (Object_t name:obj.name)
				
				local faceCount = tmesh.numfaces
				
				-------------------------------------------
				-- (b) Normals & optional Colors
				-------------------------------------------
				local normArray = #()
				normArray[faceCount*3] = [0,0,0]

				local colorArray = #()
				if impColors do ( colorArray[faceCount*3] = [1,1,1] )

				local mesh_modifier   = Edit_Mesh()
				addModifier obj mesh_modifier
				
				
				local normal_modifier_found = false
				local normal_modifier = Edit_Normals()
				for mods in obj.modifiers where classof mods == Edit_Normals do (
					normal_modifier = mods
					normal_modifier_found = true
					exit
					)
				if not normal_modifier_found do (
					addModifier obj normal_modifier
					)
				
				select obj
				modPanel.setCurrentObject normal_modifier
				subobjectLevel = 1
				local tfm = obj.transform.rotationPart as matrix3
				
				for f = 1 to faceCount do (
					for corner = 1 to 3 do (
						normArray[((f - 1) * 3) + corner] = (
							normalize (
								(transMatrix (
									normal_modifier.GetNormal (normal_modifier.GetNormalID f corner)
									)) * tfm
								).row4
							)
						)
					)
				subobjectLevel = 0
				
				if impColors do (
					for f = 1 to faceCount do (
						local cFace = getVCFace tmesh f
						for corner = 1 to 3 do (
							colorArray[((f-1)*3)+corner] = getVertColor tmesh cFace[corner]
							)
						)
					)
				
				if not normal_modifier_found do (deleteModifier obj normal_modifier)
				deleteModifier obj mesh_modifier
				
				-------------------------------------------
				-- (c) Build wvArray / biArray
				-------------------------------------------
				local wvArray = #() 
				local biArray = #() 
				
				wvArray[tmesh.numverts] = #()
				biArray[tmesh.numverts] = #()
				local num_influences = 1
				local skin_modifier = undefined
				local skin_bone = obj.parent
				if impWeights == true then (
					-- find Skin in obj.modifiers
					for m in obj.modifiers where classof m == Skin do (
						skin_modifier = m
						exit
						)
					if skin_modifier != undefined and obj.numverts > 0 then (
						select obj
						modPanel.setCurrentObject skin_modifier

						local numSkinBones = skinOps.GetNumberBones skin_modifier
						local skinBoneNames = #()
						if numSkinBones > 0 do (skinBoneNames[numSkinBones] = "")

						for i = 1 to numSkinBones do (
							local bone_list_name = skinOps.GetBoneName skin_modifier i 0
							

							skinBoneNames[i] = findItem boneNames bone_list_name
							if skinBoneNames[i] == 0 do (
								append bones (Bone_t bone_name:bone_list_name)
								append boneNames bone_list_name
								skinBoneNames[i] = boneNames.count
								)
							)

						for i = 1 to obj.numverts do (
							local wv = #()
							local bi = #()

							local numBoneWeights = skinOps.GetVertexWeightCount skin_modifier i
							
							if numBoneWeights > 0 then (
								for ii = 1 to numBoneWeights do (
									local weight = skinOps.GetVertexWeight skin_modifier i ii
									local boneID = skinBoneNames[skinOps.GetVertexWeightBoneID skin_modifier i ii]
									

									append wv weight
									append bi (boneID - 1)
									)
								)
							else (
								wv = #(1.0)
								bi = #(0)
								)

							-- clamp influences
							while wv.count > maxInfluences do (
								-- sort ascending
								for j = 1 to (wv.count-1) do (
									for k = 1 to (wv.count-j) do (
										if wv[k] > wv[k+1] do (
											swap wv[k] wv[k+1]
											swap bi[k] bi[k+1]
											)
										)
									)
								local removed = wv[1]
								for k = 2 to wv.count do (
									wv[k] += removed/(wv.count-1)
									)
									
								deleteItem wv 1
								deleteItem bi 1
								)
							
							if wv.count > num_influences do num_influences = wv.count
							
							local totalWeight = 0.0
							for x in wv do totalWeight += x
							if totalWeight != 0.0 do (
								for xx = 1 to wv.count do (
									wv[xx] /= totalWeight
									)
								)
							wvArray[i] = wv
							biArray[i] = bi
							)
						)
					else (
						-- no Skin
						if skin_bone != undefined then (
							for i = 1 to tmesh.numverts do (
								wvArray[i] = #(1.0)
								biArray[i] = #((findItem boneNames skin_bone.name) - 1)
								)
							)
						else (
							for i = 1 to tmesh.numverts do (
								wvArray[i] = #(1.0)
								biArray[i] = #(0)
								)
							)
						)
					)
				else (
					for i = 1 to tmesh.numverts do (
						wvArray[i] = #(1.0)
						biArray[i] = #(0)
						)
					)


				
				-------------------------------------------
				-- (d) Multi-Material => build face sets
				-------------------------------------------
				local baseMtl = obj.material
				local numSubs = 1
				if classof baseMtl == MultiMaterial then (
					numSubs = baseMtl.numsubs
					)
				else if classof bseMtl == Standard then (
					baseMtl = #(obj.material)
					)
				
				local faceSets = for i=1 to numSubs collect #{}
				for f=1 to faceCount do (
					local mid = getFaceMatID tmesh f
					local subIdx = if numSubs > 1 then ((mod (mid - 1) numSubs)+1) else 1
					faceSets[subIdx][f] = true
					)
				
				-------------------------------------------
				-- (e) For each sub-material => build submeshes
				-------------------------------------------
				for s=1 to numSubs do (
					if faceSets[s].isEmpty then continue
					local faceArray = for ff in faceSets[s] where ff == true collect ff
					if faceArray.count < 1 then continue
					
					local subMeshBones = #()
					local batchMesh = Mesh_t()
					batchMesh.group_index = o - 1
					batchMesh.vertices     = #()
					batchMesh.texcoords    = #()
					batchMesh.bone_ids     = #()
					batchMesh.bone_weights = #()
					batchMesh.num_bone_weights = num_influences
					batchMesh.bone_map     = #(-1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1)
					batchMesh.elements     = #()
					batchMesh.getParamsFromMat baseMtl[s] &localTextures index_ofset:allTextures.count
					
					local vertHashList = #()
					
					-- collect triangle index arrays
					local rawTris = #()
					
					for faceID in faceArray do (
						
						local triVerts = getFace tmesh faceID
						local triTV    = getTVFace tmesh faceID
						
						---------------------------------------
						-- Build localTri for this face
						---------------------------------------
						local localTri = #()
						for corner in 3 to 1 by -1 do (
							local idxV   = triVerts[corner]
							local idxTV  = triTV[corner]
							local cGlobal = ((faceID-1)*3) + corner
							
							---------------------------------------
							-- position, normal, uv
							---------------------------------------
							local pos = getVert tmesh idxV
							if rotateUp do pos = [pos.x, -pos.z, pos.y]
							pos *= mscale
							
							local nrm = normArray[cGlobal]
							if rotateUp do nrm = normalize [-nrm.x, nrm.z, -nrm.y]
							
							local uv = getTVert tmesh idxTV
							local finalUV = [uv.x, 1.0 - uv.y, 0.0]
							
							---------------------------------------
							-- Weights
							---------------------------------------
							local wv = for i=1 to num_influences collect 0.0
							local bi = for i=1 to num_influences collect 255
							wv[1] = 1.0
							bi[1] = 0
							
							if impWeights do (
								local srcW = wvArray[idxV]
								local srcB = biArray[idxV]
								for ii=1 to srcW.count do (
									if ii <= num_influences do (
										wv[ii] = srcW[ii]
										local boneIndex = findItem subMeshBones srcB[ii]
										if (boneIndex == 0) do (
											append subMeshBones srcB[ii]
											boneIndex = subMeshBones.count
											)
										-- bone_ids should be local index in subMeshBones, 0-based
										bi[ii] = boneIndex - 1
										)
									)
								)
							
							local vHash = (pos as string) \
								+ (nrm as string) \
								+ (finalUV as string) \
								+ (wv as string) \
								+ (bi as string)
							
							local vIndex = findItem vertHashList vHash
							if (optimizeVerts and vIndex != 0) then (
								vIndex -= 1
								)
							else (
								append vertHashList vHash
								vIndex = batchMesh.vertices.count
								
								append batchMesh.vertices (Vertex_t position:pos normal:nrm colour:#(0,0,0,255))
								
								append batchMesh.texcoords finalUV
								append batchMesh.bone_ids bi
								append batchMesh.bone_weights wv
								)
							
							append localTri vIndex
							)
						
						---------------------------------------
						-- If we exceed bones or 32k vertices,
						-- finalize old mesh + re-insert face
						---------------------------------------
						if (subMeshBones.count >= maxBoneMap) or (batchMesh.vertices.count > maxFaceIndex) then (
							----------------------------------------------------------------------
							-- 1) Tri-strip & finalize the old submesh
							----------------------------------------------------------------------
							local strips = #()
							if rawTris.count > 0 do (
								local currentStrip = rawTris[1]
								for t = 2 to rawTris.count do (
									local tri = rawTris[t]
									local n = currentStrip.count
									if n >= 2 then (
										if (currentStrip[n-1] == tri[1]) and (currentStrip[n] == tri[2]) then (
											append currentStrip tri[3]
											)
										else (
											append strips currentStrip
											currentStrip = tri
											)
										)
									else (
										append strips currentStrip
										currentStrip = tri
										)
									)
								append strips currentStrip
								)
							
							for st in strips do (
								local faceStruct = Face_t()
								faceStruct.type        = 6
								faceStruct.face_count  = st.count
								faceStruct.face_offset = 0
								faceStruct.faces       = st
								append batchMesh.elements faceStruct
								)
							
							batchMesh.vertex_count   = batchMesh.vertices.count
							batchMesh.texcoord_count = batchMesh.texcoords.count
							batchMesh.element_count  = batchMesh.elements.count
							
							/* 
							Because each submesh must not exceed 20 bones, 
							clamp bone_map_count to 20 if subMeshBones.count > 20.
							If your pipeline truly disallows more than 20 bones,
							you should never store the 21st bone in subMeshBones at all.
							*/
							local boneCount = subMeshBones.count
							if boneCount > 20 do boneCount = 20
							
							for bIx = 1 to boneCount do (
								-- subMeshBones[bIx] is presumably a 0-based bone ID
								-- store +1 to make bone_map base-1
								batchMesh.bone_map[bIx] = subMeshBones[bIx] + 1
								)
							batchMesh.bone_map_count = boneCount
							
							if (batchMesh.element_count > 0 or batchMesh.vertex_count > 0) do (
								append meshes batchMesh
								)
							
							------------------------------------
							-- 2) Create a NEW submesh (and
							--    reset rawTris / subMeshBones)
							------------------------------------
							
							subMeshBones = #()
							batchMesh = Mesh_t()
							batchMesh.group_index = o - 1
							batchMesh.vertices  = #()
							batchMesh.texcoords = #()
							batchMesh.bone_ids  = #()
							batchMesh.bone_weights = #()
							batchMesh.num_bone_weights = num_influences
							batchMesh.bone_map  = #(
								-1,-1,-1,-1, -1,-1,-1,-1,
								-1,-1,-1,-1, -1,-1,-1,-1,
								-1,-1,-1,-1
								)
							batchMesh.bone_map_count = 0
							batchMesh.elements  = #()
							batchMesh.getParamsFromMat baseMtl[s] &localTextures index_ofset:allTextures.count
							vertHashList        = #()
							
							-- ***** IMPORTANT: Clear old rawTris so we
							-- can start from scratch in the new submesh
							rawTris = #()
							
							------------------------------------
							-- 3) Re-insert the face that triggered
							--    the split into the new submesh
							------------------------------------
							local newTri = #()
							for corner in 3 to 1 by -1 do (
								local idxV   = triVerts[corner]
								local idxTV  = triTV[corner]
								local cGlobal = ((faceID-1)*3) + corner
								
								local pos = getVert tmesh idxV
								if rotateUp do pos = [pos.x, -pos.z, pos.y]
								pos *= mscale
								
								local nrm = normArray[cGlobal]
								if rotateUp do nrm = normalize [-nrm.x, nrm.z, -nrm.y]
								
								local uv = getTVert tmesh idxTV
								local finalUV = [uv.x, 1.0 - uv.y, 0.0]
								
								local wv = for i=1 to maxInfluences collect 0.0
								local bi = for i=1 to maxInfluences collect 255
								wv[1] = 1.0
								bi[1] = 0
								
								if impWeights do (
									local srcW = wvArray[idxV]
									local srcB = biArray[idxV]
									for ii=1 to srcW.count do (
										if ii <= maxInfluences do (
											wv[ii] = srcW[ii]
											local boneIndex = findItem subMeshBones srcB[ii]
											if (boneIndex == 0) do (
												append subMeshBones srcB[ii]
												boneIndex = subMeshBones.count
												)
											-- bone_ids should be local index in subMeshBones, 0-based
											bi[ii] = boneIndex - 1
											)
										)
									)
								
								local vHash = (pos as string) \
									+ (nrm as string) \
									+ (finalUV as string) \
									+ (wv as string) \
									+ (bi as string)
								
								local vIndex = findItem vertHashList vHash
								if (optimizeVerts and vIndex != 0) then (
									vIndex -= 1
									)
								else (
									append vertHashList vHash
									vIndex = batchMesh.vertices.count
									
									append batchMesh.vertices \
									(Vertex_t position:pos normal:nrm colour:#(0,0,0,255))
									
									append batchMesh.texcoords finalUV
									append batchMesh.bone_ids bi
									append batchMesh.bone_weights wv
									)
								append newTri vIndex
								)
							append rawTris newTri
							)
						else (
							-- If no split needed, just push localTri
							append rawTris localTri
							)
						)
					
					-----------------------------------------------------
					-- Done building rawTris for this sub-material
					-- Next: we do tri-strips but *NO* second vertex-limit check
					-----------------------------------------------------
					local strips = #()
					if rawTris.count > 0 do (
						local currentStrip = rawTris[1]
						for t=2 to rawTris.count do (
							local tri = rawTris[t]
							local n   = currentStrip.count
							if n >= 2 then (
								local lastA = currentStrip[n-1]
								local lastB = currentStrip[n]
								if (lastA == tri[1]) and (lastB == tri[2]) then (
									-- extend current strip
									append currentStrip tri[3]
									)
								else (
									-- close current strip, start new
									append strips currentStrip
									currentStrip = tri
									)
								)
							else (
								append strips currentStrip
								currentStrip = tri
								)
							)
						append strips currentStrip
						)
					
					-----------------------------------------------------
					-- Now add the final Face_t's to batchMesh
					-----------------------------------------------------
					for st in strips do (
						local faceStruct = Face_t()
						faceStruct.type         = 6
						faceStruct.face_count   = st.count
						faceStruct.face_offset  = 0
						faceStruct.faces        = st
						
						append batchMesh.elements faceStruct
						)
					
					batchMesh.vertex_count   = batchMesh.vertices.count
					batchMesh.texcoord_count = batchMesh.texcoords.count
					batchMesh.element_count  = batchMesh.elements.count
					
					for bIx=1 to subMeshBones.count do (
						if bIx <= 20 do (
							-- 0-based indexing for final
							batchMesh.bone_map[bIx] = subMeshBones[bIx] + 1
							)
						)
					if batchMesh.element_count > 0 do (
						append meshes batchMesh
						)
					) -- end for each sub-material
				delete tmesh
				object_names[o].num_textures = localTextures.count
				join allTextures localTextures
				) -- end for obj in meshObjs
			
			-------------------------------------------
			-- Store object names
			-------------------------------------------
			object_name_count = object_names.count

			-------------------------------------------
			-- store meshes in your final array
			-------------------------------------------
			mesh_count   = meshes.count

			-------------------------------------------
			-- gather textures (if you want)
			-------------------------------------------
			--local allTextures = #()
			--join textures #("0800far01", "0800far01_n", "0800far02", "0800far02_n", "0800far03", "0800far03_n", "0800far04", "0800far04_n")
			textures = allTextures
			texture_count = allTextures.count
			
			messageBox "Export done!"
			),
		
		fn read f = (
			f.bigEndian()
			fileid = f.read_ulong()
			if fileid == 0x4A424F59 then (
				filesize = f.read_ulong()
				local pos = f.tell()
				reserve0 = f.read_ulong()
				pof0_offset = f.read_ulong()
				reserve1 = f.read_ulong()
				reserve2 = f.read_ulong()
				mesh_count = f.read_ulong()
				mesh_offset = f.read_ulong()
				skel_count = f.read_ulong()
				texture_count = f.read_ulong()
				skel_offset = f.read_ulong()
				texture_offset = f.read_ulong()
				object_name_offset = f.read_ulong()
				object_name_count = f.read_ulong()
				reserve3 = f.read_ulong()
				reserve4 = f.read_ulong()
				reserve5 = f.read_ulong()
				reserve6 = f.read_ulong()
				
				meshes = #()
				
				--printInfo()
				
				--format "mesh_count: \t%\n" mesh_count
				if mesh_count > 0 do (
					meshes[mesh_count] = Mesh_t()
					f.seek(pos + mesh_offset)
					--format "mesh_offset: \t%\n" ((pos + mesh_offset) as integer)
					for i = 1 to mesh_count do (
						meshes[i] = Mesh_t()
						meshes[i].read(f)
						
						-- Reset all Material Parameters
						meshes[i].mat_params = #()
						)
					
					-- The mesh data is then striped throughout
					for i = 1 to mesh_count do (
						
						-- Read Material Parameters
						if meshes[i].mat_param_offset > 0 and meshes[i].mat_param_count > 0 do (
							
							-- Read Pointers for Each Material Parameter
							f.seek(pos + meshes[i].mat_param_offset)
							meshes[i].mat_param_addrs = #()
							meshes[i].mat_param_addrs[meshes[i].mat_param_count] = 0
							for j = 1 to meshes[i].mat_param_count do (
								meshes[i].mat_param_addrs[j] = f.read_ulong()
								)
							
							
							-- Read Each Parameter
							meshes[i].mat_params[meshes[i].mat_param_count] = Material_t()
							for j = 1 to meshes[i].mat_param_count do (
								f.seek(pos + meshes[i].mat_param_addrs[j])
								meshes[i].mat_params[j] = Material_t()
								meshes[i].mat_params[j].read(f)
								)
							)
						
						-- Read Vertex Data
						if meshes[i].vertex_buf_offset > 0 and meshes[i].vertex_count > 0 do (
							f.seek(pos + meshes[i].vertex_buf_offset)
							
							meshes[i].vertex_offset = f.read_ulong()
							
							f.seek(pos + meshes[i].vertex_offset)
							meshes[i].vertices[meshes[i].vertex_count] = Vertex_t()
							
							for j = 1 to meshes[i].vertex_count do (
								meshes[i].vertices[j] = Vertex_t()
								meshes[i].vertices[j].read(f)
								)
							
							-- Read Blend Weights
							if meshes[i].weight_offset > 0 and meshes[i].num_bone_weights > 0 do (
								f.seek(pos + meshes[i].weight_offset)
								
								meshes[i].bone_ids[meshes[i].vertex_count] = #()
								meshes[i].bone_weights[meshes[i].vertex_count] = #()
								
								for j = 1 to meshes[i].vertex_count do (
									meshes[i].bone_ids[j] = #()
									meshes[i].bone_weights[j] = #()
									meshes[i].bone_ids[j][meshes[i].num_bone_weights] = 0
									meshes[i].bone_weights[j][meshes[i].num_bone_weights] = 0.0
									
									for k = 1 to meshes[i].num_bone_weights do (
										meshes[i].bone_ids[j][k] = f.read_ubyte()
										f.read_ubyte() -- padding
										f.read_ubyte() -- padding
										f.read_ubyte() -- padding
										meshes[i].bone_weights[j][k] = f.read_float()
										)
									)
								)
							
							)
						
						-- Read Texture Coordinates
						if meshes[i].texcoord_offset > 0 and meshes[i].texcoord_count > 0 do (
							f.seek(pos + meshes[i].texcoord_offset)
							
							meshes[i].texcoords[meshes[i].texcoord_count] = [0.0, 0.0, 0.0]
							for j = 1 to meshes[i].texcoord_count do (
								meshes[i].texcoords[j] = [f.read_float(), f.read_float(), 0.0]
								)
							)
						
						-- Read Faces
						--format "Elements: \t%\n" meshes[i].element_count
						if meshes[i].element_offset > 0 and meshes[i].element_count > 0 do (
							
							-- Read Face Info
							f.seek(pos + meshes[i].element_offset)
							meshes[i].elements[meshes[i].element_count] = Face_t()
							for j = 1 to meshes[i].element_count do (
								meshes[i].elements[j] = Face_t()
								meshes[i].elements[j].read(f)
								
								)
							
							-- Read Face Indices
							for j = 1 to meshes[i].element_count do (
								f.seek(pos + meshes[i].elements[j].face_offset)
								if meshes[i].elements[j].face_count > 0 do (
									meshes[i].elements[j].faces[meshes[i].elements[j].face_count] = 0
									for k = 1 to meshes[i].elements[j].face_count do (
										meshes[i].elements[j].faces[k] = f.read_ushort()
										
										)
									
									)
								)
							)
						)
					)
				
				bones = #()
				if skel_offset > 0 and skel_count > 0 do (
					f.seek(pos + skel_offset)
					
					bones[skel_count] = Bone_t()
					for i = 1 to skel_count do (
						bones[i] = Bone_t()
						bones[i].read(f)
						)
					)
				
				textures = #()
				if texture_offset > 0 and texture_count > 0 do (
					
					f.seek(pos + texture_offset)
					textures[texture_count] = ""
					for i = 1 to texture_count do (
						textures[i] = f.read_string length:16
						)
					
					--print textures
					)
				
				object_names = #()
				if object_name_offset > 0 and object_name_count > 0 do (
					
					f.seek(pos + object_name_offset)
					object_names[object_name_count] = Object_t()
					for i = 1 to object_name_count do (
						object_names[i] = Object_t()
						object_names[i].read(f)
						)
					
					--print object_names
					)
				
				if pof0_offset > 0 and (pos + pof0_offset) <= f.size do (
					f.seek(pos + pof0_offset)
					pof0.read(f)
					)
				
				--format "last read at %\n" (f.tell() as integer)
				) else (format "Error: \tInvalid File ID {0x%}\n" (bit.IntAsHex fileid))
			),
		
		fn write &s = (
			
			update_pointers()
			
			s.bigEndian()
			s.write_ulong(fileid)
			s.write_ulong(filesize)
			s.write_ulong(reserve0)
			s.write_ulong(pof0_offset)
			s.write_ulong(reserve1)
			s.write_ulong(reserve2)
			s.write_ulong(mesh_count)
			s.write_ulong(mesh_offset)
			s.write_ulong(skel_count = bones.count)
			s.write_ulong(texture_count = textures.count)
			s.write_ulong(skel_offset)
			s.write_ulong(texture_offset)
			s.write_ulong(object_name_offset)
			s.write_ulong(object_name_count = object_names.count)
			s.write_ulong(reserve3)
			s.write_ulong(reserve4)
			s.write_ulong(reserve5)
			s.write_ulong(reserve6)
			
			-- Write Meshes
			if mesh_count > 0 do (
				for m in meshes do (
					m.write(&s)
					)
				for m in meshes do (
					
					-- Write Material Parameters
					if m.mat_param_count > 0 do (
						
						-- Write Pointers for Each Material Parameter
						for i in m.mat_param_addrs do (
							s.write_ulong(i)
							)
						
						-- Write Each Parameter
						for p in m.mat_params do (
							p.write(&s)
							)
						)
					
					-- Write Vertex Data
					if m.vertex_count > 0 do (
						s.write_ulong(m.vertex_offset)
						
						
						for v in m.vertices do (
							v.write(&s)
							)
						
						-- Write Blend Weights
						if m.num_bone_weights > 0 and m.bone_ids.count == m.vertex_count and m.bone_weights.count == m.vertex_count do (
							for j = 1 to m.vertex_count do (
								for k = 1 to m.num_bone_weights do (
									s.write_ubyte(m.bone_ids[j][k])
									s.write_ubyte(0) -- padding
									s.write_ubyte(0) -- padding
									s.write_ubyte(0) -- padding
									s.write_float(m.bone_weights[j][k])
									)
								)
							)
						)
					
					-- Write Texture Coordinates
					if m.texcoord_count > 0 do (
						for uv in m.texcoords do (
							s.write_float(uv[1])
							s.write_float(uv[2])
							)
						)
					
					-- Write Faces
					if m.element_count > 0 do (
						
						-- Write Face Info
						for finfo in m.elements do (
							finfo.write(&s)
							)
						
						-- Write Face Indices
						for strip in m.elements do (
							
							if strip.face_count > 0 do (
								
								for face in strip.faces do (
									s.write_ushort(face)
									)
								
								if bit.and strip.face_count 1 == 1 do (
									s.write_ushort(0)
									)
								)
							)
						)
					)
				)
			
			-- Write Bones
			if skel_count > 0 do (
				for bb in bones do (
					bb.write(&s)
					)
				)
			
			-- Write Mesh Names
			if texture_count > 0 do (
				for str in textures do (
					s.write_string str length:16
					)
				)
			
			-- Write object_names
			if object_name_count > 0 do (
				for att in object_names do (
					att.write(&s)
					)
				)
			
			-- Write Pointer Offsets
			if pof0.offsets.count > 0 do (
				pof0.write(&s)
				)
			),
		
		fn save file = (
			if file != undefined and file != "" do (
				local s = bytestream()
				if s.open file mode:"wb" then (
					
					write(&s)
					
					s.close()
					) else (format "failed to save file {%}\n" file)
				)
			),
		
		fn open file = (
			if file != undefined and file != "" do (
				local f = bytestream()
				if f.open(file) then (
					
					read(f)
					
					f.close()
					
					--import()
					--save("C:\\Users\\Corey\\Documents\\Xenia\\content\\4B4E07D1\\00000002\\Aigle Normal\\e508\\0\\0\\ymm\\0020_new.jboy")
					) else (format "failed to open file {%}\n" file)
				)
			)
		
		)
	
	fn read file = (
		local yobj = YokesObject_t()
		yobj.open(file)
		)
	fn write file = (
		local yobj = YokesObject_t()
		
		
		--yobj.open("C:\\Users\\Corey\\Documents\\Xenia\\content\\4B4E07D1\\00000002\\Aigle Normal\\e508\\0\\0\\ymm\\bs_waist_f - Copy.ymxen")
		
		yobj.export()
		--append yobj.meshes[1].elements yobj.meshes[1].elements[1]
		print yobj.meshes.count
		yobj.save(file)
		)
	
	on btn2 pressed do (
		local file = GetOpenFileName caption:"Select Model File" types:"All Supported Formats (*.yobj, *.jboy, *.ymxen)|*.YOBJ;*.JBOY;*.YMXEN|All files (*.*)|*.*|"
		if file != undefined and file != "" do (
			local yobj = YokesObject_t()
			yobj.open(file)
			yobj.import \
				mscale:spn1.value \
				clearScene:chk0.checked \
				rotateUp:true \
				matDeepMerge:false \
				impColors:chk3B.checked \
				impWeights:chk3.checked \
				impNormals:chk2B.checked \
				impMesh:chk1.checked
			last_path = getFilenamePath file
			)
		)
	
	on btn3 pressed do (
		local file = getSaveFileName caption:"Save Model File" types: "Yokes Mesh (*.ymxen)|*.YMXEN|All files (*.*)|*.*|"
		if file != "" and file != undefined do (
			local yobj = YokesObject_t()
			yobj.export()
			yobj.save(file)
			)
		)
	
	on btn3C pressed do (
		local file = GetOpenFileName caption:"Select Model File" types:"All Supported Formats (*.yobj, *.jboy, *.ymxen)|*.YOBJ;*.JBOY;*.YMXEN|All files (*.*)|*.*|"
		if file != "" and file != undefined do (
			local yobj = YokesObject_t()
			yobj.open(file)
			yobj.save((getFilenamePath file) + (getFilenameFile file) + "_new" + (getFilenameType file))
			messageBox "Done!"
			)
		)
	
	on btn4 pressed do (
		local dir_path = getSavePath caption:"Texture Path" initialDir:last_path
		if dir_path != undefined and dir_path != "" do (
			local tex = Tex_t()
			tex.pack dir_path directWrite:(not chkUseDos.checked)
			messageBox ((tex.entries.count as string)+" Packed!")
			)
		)
	
	on btn4b pressed do (
		local file = GetOpenFileName caption:"Open Tex File" types: "Tex (*.text)|*.TEX|All files (*.*)|*.*|"
		if file != "" and file != undefined do (
			local f = bytestream()
			
			if f.open(file) then (
				local tex = Tex_t()
				tex.read f outpath:(getFilenamePath file)
				f.close()
				messageBox ((tex.entries.count as string)+" Files Written!")
				)
			)
		)
	-------------------------------------------------------------------------
	-- Pick Source Object
	-------------------------------------------------------------------------
	on btn_pickSource picked obj do (
		sourceObj = obj
		if isProperty sourceObj #material and sourceObj.material != undefined then (
			format "Picked source object: %\n" sourceObj.name
			)
		else (
			messageBox "Selected object has no valid material."
			sourceObj = undefined
			)
		)
	
	-------------------------------------------------------------------------
	-- Copy the chosen sub-material from the Source
	-------------------------------------------------------------------------
	on btn_copyMaterial pressed do (
		if sourceObj != undefined and sourceObj.material != undefined then (
			if classof sourceObj.material == MultiMaterial then (
				local idx = spn_matIndex.value
				local mm  = sourceObj.material
				
				if (idx >= 1) and (idx <= mm.numsubs) then (
					local tempMat = mm[idx]
					if tempMat != undefined do (
						-- Copy entire sub-material
						local oldDiffuse = tempMat.diffuseMap
						copiedSubMat = copy tempMat
						copiedSubMat.diffuseMap = oldDiffuse
						
						messageBox ("Sub-material #" + idx as string + " copied!\n\n" + 
									"Now select the objects you want to overwrite,\n" +
									"and click 'Override Materials (Selection)'.")
						)
					)
				else (
					messageBox ("Sub-material index " + idx as string + " is out of range.")
					)
				)
			else (
				messageBox "Source object does not have a Multi/Sub material."
				)
			)
		else (
			messageBox "No valid source object or material selected."
			)
		)
	
	-------------------------------------------------------------------------
	-- Override the materials for the currently selected objects
	-------------------------------------------------------------------------
	on btn_override pressed do (
		if copiedSubMat != undefined then (
			if selection.count != 0 then (
				
				-- Confirm override
				if queryBox "This will override the materials for all selected objects. Proceed?" title:"Confirm Material Override" then (
					for obj in selection do (
						if isProperty obj #material and obj.material != undefined then (
							local theMat = obj.material
							if classof theMat == MultiMaterial then (
								for s = 1 to theMat.numsubs do (
									local oldDiffuse = theMat[s].diffuseMap
									theMat[s] = copy copiedSubMat
									if oldDiffuse != undefined do (
										theMat[s].diffuseMap = oldDiffuse
										if custAttributes.count theMat[s] > 0 do (
											
											local attr = custAttributes.get theMat[s] 1
											
											if isProperty theMat[s] #g_texDiffuse do (
												attr.g_texDiffuse = oldDiffuse
												)
											if isProperty theMat[s] #texDiffuse do (
												attr.texDiffuse = oldDiffuse
												)
											)
										)
									)
								)
							else if classof theMat == standard then (
								local oldDiffuse = theMat.diffuseMap
								obj.material = copy copiedSubMat
								if oldDiffuse != undefined do (
									obj.material.diffuseMap = oldDiffuse
									if custAttributes.count theMat > 0 do (
										
										local attr = custAttributes.get theMat 1
										
										if isProperty theMat #g_texDiffuse do (
											attr.g_texDiffuse = oldDiffuse
											)
										if isProperty theMat #texDiffuse do (
											attr.texDiffuse = oldDiffuse
											)
										)
									)
								)
							else if classof theMat == Physical_Material then (
								local oldDiffuse = theMat.base_color_map
								obj.material = copy copiedSubMat
								if oldDiffuse != undefined do (
									obj.material.diffuseMap = oldDiffuse
									if custAttributes.count theMat > 0 do (
										
										local attr = custAttributes.get theMat 1
										
										if isProperty theMat #g_texDiffuse do (
											attr.g_texDiffuse = oldDiffuse
											)
										if isProperty theMat #texDiffuse do (
											attr.texDiffuse = oldDiffuse
											)
										)
									)
								)
							else (
								obj.material = copy copiedSubMat
								)
							)
						else (
							-- If the object has no material, create a Multi/Sub with 1 slot
							local newMM = MultiMaterial numsubs:1
							newMM[1] = copy copiedSubMat
							obj.material = newMM
							)
						
						redrawViews()  -- refresh
						)
					
					messageBox "Material override complete!"
					)
				else (
					messageBox "Operation canceled."
					)
				) else (messageBox "No objects selected.")
			) else (messageBox "No sub-material copied yet.")
		)
	
	)
CreateDialog rrxx_util
/*
rrxx_util.read(
-- 	"E:\\BackUp\\TREKSTOR\\_3DMODELS\\Ripped\\Rumble Roses XX\\ed\\ex00\\M600\\18.YOBJ"
-- 	"E:\\BackUp\\TREKSTOR\\_3DMODELS\\Ripped\\Rumble Roses XX\\sys\\bg\\0002\\332.YOBJ"
-- 	"E:\\BackUp\\TREKSTOR\\_3DMODELS\\Ripped\\Rumble Roses XX\\sys\\bg\\0002\\333.YOBJ"
-- 	"E:\\BackUp\\TREKSTOR\\_3DMODELS\\Ripped\\Rumble Roses XX\\sys\\bg\\0002\\362.YOBJ"
-- 	"E:\\BackUp\\TREKSTOR\\_3DMODELS\\Ripped\\Rumble Roses XX\\ed\\ex00\\M500\\35.YOBJ"
	"G:\\RumbleRosesXX\\_DUMP\\0.BPE (220).YOBJ" -- cube
-- 	"G:\\RumbleRosesXX\\_DUMP\\465 (2).YOBJ"
-- 	"C:\\Users\\Corey\\Documents\\Xenia\\content\\4B4E07D1\\00000002\\Aigle Normal\\e508\\0\\0\\ymm\\bs_waist.ymxen"
-- 	"G:\\RumbleRosesXX\\0000_TheRock_SvR10.jboy"
-- 	"G:\\RumbleRosesXX\\200 (SRV).YOBJ"
	"G:\\RumbleRosesXX\\NEWFILE.yobj"
	)
*/

-- rrxx_util.write("C:\\Users\\Corey\\Documents\\Xenia\\content\\4B4E07D1\\00000002\\Aigle Normal\\e508\\0\\0\\ymm\\bs_waist_f.ymxen")
-- rrxx_util.read("G:\\RumbleRosesXX\\NEWFILE.yobj")

-- rrxx_util.read("C:\\Users\\Corey\\Documents\\Xenia\\content\\4B4E07D1\\00000002\\Aigle Normal\\e508\\0\\0\\ymm\\bs_waist_f - Copy.ymxen")
-- rrxx_util.read("C:\\Users\\Corey\\Documents\\Xenia\\content\\4B4E07D1\\00000002\\Aigle Normal\\e508\\0\\0\\ymm\\bs_waist - Copy.ymxen")

-- rrxx_util.read("C:\\Users\\Corey\\Documents\\Xenia\\content\\4B4E07D1\\00000002\\Aigle Normal\\e508\\0\\0\\ymm\\bs_waist.ymxen")
-- rrxx_util.write("C:\\Users\\Corey\\Documents\\Xenia\\content\\4B4E07D1\\00000002\\Aigle Normal\\e508\\0\\0\\ymm\\bs_waist.ymxen")
-- rrxx_util.read("C:\\Users\\Corey\\Documents\\Xenia\\content\\4B4E07D1\\00000002\\Aigle Normal\\e508\\0\\0\\ymm\\0020.jboy")
