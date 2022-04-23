function instructions_scene_create()
  local scene = {
    background = background_create(),
    instructions = {
      {
        text = 'the aim of the game is to get\nthe block to fall into the\nsquare hole at the end of each\nstage. there are 33 stages to\ncomplete.',
        playback = {
          level = 0,
          keys = { -1, ⬅️, ⬅️, -1 },
        },
      },
      {
        text = 'to move the block around the\nworld, use ⬅️➡️⬆️⬇️.',
        playback = {
          level = 1,
          keys = { ➡️, ⬇️, ⬅️, ⬆️ },
          loop = true,
        },
      },
      {
        text = 'be careful not to fall off the\nedges - the level will be\nrestarted if this happens.',
        playback = {
          level = 2,
          keys = { -1, ⬅️, -1, -1, -1, ➡️, -1, -1, -1, ⬆️, -1, -1, -1, ⬇️, -1 },
        },
      },
      {
        text = 'bridges and switches are\nlocated in many levels. the\nswitches are activated when\nthey are pressed down by the\nblock. you do not need to stay\nresting on the switch to keep\nbridges closed.',
        playback = {
          level = 3,
          keys = { -1, ➡️, ⬇️, ➡️, ⬅️, ⬇️, ⬇️, ➡️, ⬅️, -1 },
        },
      },
      {
        text = 'there are two types of\nswitches: \'heavy\' x-shaped\nones and \'soft\' round ones.\nsoft switches are activated\nwhen any part of your block\npresses it.',
      },
      {
        text = 'hard switches require much\nmore pressure, so your block\nmust be standing on its end to\nactivate them.',
      },
      {
        text = 'when activated, each switch\nmay behave differently. some\nwill swap the bridges from\nopen to closed to open each\ntime it is used. some will\nonly ever make certain bridges\nopen, and activating it again\nwill not make it close.',
        playback = {
          level = 4,
          keys = { -1, ➡️, ➡️, ⬅️, ➡️, ⬅️, ⬇️, ➡️, ⬅️, ➡️, ⬅️, ⬇️, ➡️, ⬅️, ➡️, ⬅️, -1 },
        },
      },
      {
        text = 'green or red coloured squares\nwill flash to indicate which\nbridges are being operated.',
      },
      {
        text = 'orange tiles are more fragile\nthan the rest of the land. if\nyour block stands up\nvertically on an orange tile,\nthe tile will give way and\nyour block will fall.',
        playback = {
          level = 5,
          keys = { -1, ⬇️, ➡️, ➡️, ➡️, ➡️, ⬇️, -1 },
        },
      },
      {
        text = 'finally, there is a third type\nof switch shaped like\nthis: ( )',
        playback = {
          level = 6,
          keys = { -1, ➡️, ➡️, -1, ➡️, '🅾️', -1, ⬅️, ⬇️, -1 },
        },
      },
      {
        text = 'it teleports your block to\ndifferent locations, splitting\nit into two smaller blocks at\nthe same time. these can be\ncontrolled individually and\nwill rejoin into a normal\nblock when both are placed\nnext to each other.'
      },
      {
        text = 'you can select which small\nblock to use at any time by\npressing 🅾️. small blocks can\nstill operate soft switches,\nbut they aren\'t big enough to\nactivate heavy switches.'
      },
      {
        text = 'also small blocks cannot go\nthrough the exit hole - only a\ncomplete block can finish\nthe stage.'
      },
      {
        text = 'remember the passcode for each\nstage. it is located in the\ntop right corner. you can skip\nstraight back to each stage\nlater on by going to\n\'load stage\' in the main menu\nand entering the 6 digit level\ncode.'
      },
    },
    instruction = 0,
    reset_instruction = instructions_reset_instruction,
    update = instructions_scene_update,
    draw = instructions_scene_draw,
  }

  scene:reset_instruction()

  return scene
end

function instructions_reset_instruction(self)
  local playback = self.instructions[self.instruction + 1].playback
  if playback ~= nil then
    self.playback = playback_create(playback.level, playback.keys, playback.loop)
  end
end

function instructions_scene_update(self)
  self.playback:update()
  if btnp(🅾️) then
    self.instruction += 1
    if self.instruction >= #self.instructions then
      show_game()
    else
      self:reset_instruction()
    end
  elseif btnp(❎) then
    show_game()
  end
end

function instructions_scene_draw(self)
  self.background:draw()
  map(96, 34, 0, 0, 16, 16)
  self.playback:draw()
  print((self.instruction + 1)..'/'..#self.instructions, 4, 4, 7)
  print('         🅾️: next     ❎: skip', 4, 4, 7)
  print(self.instructions[self.instruction + 1].text, 4, 12, 7)
end
