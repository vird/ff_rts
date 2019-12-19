#!/usr/bin/env iced
require 'fy'
{
  Emulator
  FF_emulator
  State
} = require './src/index.coffee'
state_collection = require './test/state_collection/index.coffee'


argv = require('minimist')(process.argv.slice(2))

if !state_name = argv._[0]
  puts "usage ./manual_test.coffee <state_name>"
  process.exit()


if argv.ff
  emu = new FF_emulator
else
  emu = new Emulator

obj_set emu, state_collection[state_name]()
if argv.tick?
  emu.tick_limit = argv.tick
result = emu.go()

p emu.state