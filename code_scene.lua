function code_scene_create()
  local scene = {
    update = code_scene_update,
    draw = code_scene_draw,
  }

  return scene
end

function code_scene_update()
end

function code_scene_draw()
end
