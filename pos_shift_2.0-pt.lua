-- Por Youka - Melhorado por tophf - Corrigido/Traduzido por Leinad4Mind
--

script_name = "Desclocar Posicionamento"
script_description = "Deslocar Posições."
script_author = "Youka, tophf e Leinad4Mind"
script_version = "2.0"
script_modified = "6 de Outubro 2012"

--Configuration
function create_config()
	return {
		{ class="label", x=0, y=0, width=1, height=1, label="\pos(" },
		{ class="floatedit", name="pos_x", x=1, y=0, width=1, height=1, value=0.00, hint="Deslocar coordenada x de \pos" },
		{ class="label", x=2, y=0, width=1, height=1, label="," },
		{ class="floatedit", name="pos_y", x=3, y=0, width=1, height=1, value=0.00, hint="Deslocar coordenada y de \pos" },
		{ class="label", x=4, y=0, width=1, height=1, label=")" },
		{ class="label", x=0, y=1, width=1, height=1, label="\move(" },
		{ class="floatedit", name="move_x1", x=1, y=1, width=1, height=1, value=0.00, hint="Deslocar primeira coordenada x de \move" },
		{ class="label", x=2, y=1, width=1, height=1, label="," },
		{ class="floatedit", name="move_y1", x=3, y=1, width=1, height=1, value=0.00, hint="Deslocar primeira coordenada y de \move" },
		{ class="label", x=4, y=1, width=1, height=1, label="," },
		{ class="floatedit", name="move_x2", x=5, y=1, width=1, height=1, value=0.00, hint="Deslocar segunda coordenada x de \move" },
		{ class="label", x=6, y=1, width=1, height=1, label="," },
		{ class="floatedit", name="move_y2", x=7, y=1, width=1, height=1, value=0.00, hint="Deslocar segunda coordenada y de \move" },
		{ class="label", x=8, y=1, width=1, height=1, label="(, ?, ?) )" },
		{ class="label", x=0, y=2, width=1, height=1, label="\org(" },
		{ class="floatedit", name="org_x", x=1, y=2, width=1, height=1, value=0.00, hint="Deslocar coordenada x de \org" },
		{ class="label", x=2, y=2, width=1, height=1, label="," },
		{ class="floatedit", name="org_y", x=3, y=2, width=1, height=1, value=0.00, hint="Deslocar coordenada y de \org" },
		{ class="label", x=4, y=2, width=1, height=1, label=")" },
		{ class="label", x=0, y=3, width=1, height=1, label="Clips:  x:" },
		{ class="floatedit", name="clip_x", x=1, y=3, width=1, height=1, value=0.00, hint="Deslocar coordenada x de \pos" },
		{ class="label", x=2, y=3, width=1, height=1, label=" y:" },
		{ class="floatedit", name="clip_y", x=3, y=3, width=1, height=1, value=0.00, hint="Deslocar coordenada y de \pos" }
	}
end

--Shift positions of selected lines
function pos_shift(subs,sel,config)

	for x, i in ipairs(sel) do
		local a = subs[i]
		local function float2str(f) return tostring(f):gsub("%.(.-)0+$","%1"):gsub("%.$","") end
		local function pos_repl(x,y) return "\\pos("..float2str(x+config.pos_x)..","..float2str(y+config.pos_y)..")" end
		local function org_repl(x,y) return "\\org("..float2str(x+config.org_x)..","..float2str(y+config.org_y)..")" end
		local function move_repl(x, y, x2, y2, t) return "\\move("..float2str(x+config.move_x1)..","..float2str(y+config.move_y1)..","..float2str(x2+config.move_x2)..","..float2str(y2+config.move_y2)..tostring(t or "")..")" end
		local function rec_clip_repl(clip, x1, y1, x2, y2) return "\\"..clip.."("..float2str(x1+config.clip_x)..","..float2str(y1+config.clip_y)..","..float2str(x2+config.clip_x)..","..float2str(y2+config.clip_y)..")" end
		local function vec_clip_repl(clip, acc, shape) return "\\"..clip.."("..acc..string.gsub(shape or acc,"(-?%d+)%s*(-?%d+)", function(x,y) return float2str(x+config.clip_x).." "..float2str(y+config.clip_y) end)..")" end
		a.text = a.text:gsub("\\pos%((%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*)%)",pos_repl,1)
		a.text = a.text:gsub("\\move%((%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*)([%d%,%s]-)%)",move_repl,1)
		a.text = a.text:gsub("\\org%((%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*)%)",org_repl,1)
		a.text = a.text:gsub("\\(i?clip)%((%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*),(%s*%-?[%d%.]+%s*)%)",rec_clip_repl,1) --\(i)clip (rectangle)
		a.text = a.text:gsub("\\(i?clip)%((%s*%d*%s*%,?)([mlbsc%s%d%-]+)%)",vec_clip_repl,1) --\(i)clip (vectors)
		subs[i] = a
	end

end

--Initialisation + GUI
function load_macro_pos(subs,sel)
	local sh, config = aegisub.dialog.display(create_config(subs,meta),{"Shift","Cancel"})
	if sh=="Shift" then
		pos_shift(subs,sel,config)
		aegisub.set_undo_point(script_name)
	end
end

--Test for activation
function test_pos(text)
	return text:match("\\pos%(%s*%-?[%d%.]+%s*,%s*%-?[%d%.]+%s*%)")
		or text:match("\\move%(%s*%-?[%d%.]+%s*,%s*%-?[%d%.]+%s*,%s*%-?[%d%.]+%s*,%s*%-?[%d%.]+%s*%)")
		or text:match("\\move%(%s*%-?[%d%.]+%s*,%s*%-?[%d%.]+%s*,%s*%-?[%d%.]+%s*,%s*%-?[%d%.]+%s*,%s*%d+%s*,%s*%d+%s*%)")
		or text:match("\\org%((%s*%-?[%d%.]+%s*,%s*%-?[%d%.]+%s*)%)")
end

function activate_macro_pos(subs, sel)
	for x, i in ipairs(sel) do if not test_pos(subs[i].text) then return false end end
	return true
end

--Register macro in aegisub
aegisub.register_macro(script_name,script_description, load_macro_pos, activate_macro_pos)
