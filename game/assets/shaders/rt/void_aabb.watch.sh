inotifywait -e modify \
  '/home/olivier/projects/g4d/src/v4d/game/assets/shaders/rt/void_aabb.glsl'

if [[ -e '/home/olivier/projects/g4d/build/debug/game/assets/shaders/rt/void_aabb.meta' ]] ; then
  echo "
  "
  '/home/olivier/projects/g4d/build/shadercompiler' '/home/olivier/projects/g4d/src/v4d/game/assets/shaders/rt/void_aabb.glsl' '/home/olivier/projects/g4d/build/debug/game/assets/shaders/rt/void_aabb.meta' '/home/olivier/projects/g4d/src' '/home/olivier/projects/g4d/src/v4d/core/utilities/graphics/shaders'
  echo "
  "
  sh -c $0 
fi
