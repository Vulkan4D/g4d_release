inotifywait -e modify \
  '/home/olivier/projects/g4d/src/v4d/game/assets/shaders/rt/cone.glsl'\
  '/home/olivier/projects/g4d/src/v4d/game/graphics/glsl/base.glsl'\
  '/home/olivier/projects/g4d/src/v4d/game/graphics/glsl/../cpp_glsl.hh'\
  '/home/olivier/projects/g4d/src/v4d/core/utilities/graphics/shaders/cpp_glsl_head_glsl.hh'

if [[ -e '/home/olivier/projects/g4d/build/debug/game/assets/shaders/rt/cone.meta' ]] ; then
  echo "
  "
  '/home/olivier/projects/g4d/build/shadercompiler' '/home/olivier/projects/g4d/src/v4d/game/assets/shaders/rt/cone.glsl' '/home/olivier/projects/g4d/build/debug/game/assets/shaders/rt/cone.meta' '/home/olivier/projects/g4d/src' '/home/olivier/projects/g4d/src/v4d/core/utilities/graphics/shaders'
  echo "
  "
  sh -c $0 
fi
