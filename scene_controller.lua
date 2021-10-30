local scene = nil

function show_menu()
  scene = menu_scene_create()
end

function show_game()
  scene = game_scene_create()
end

function _update()
  if scene ~= nil then
	  scene:update()
  end
end

function _draw()
  cls()
  if scene ~= nil then
	  scene:draw()
  end
end
