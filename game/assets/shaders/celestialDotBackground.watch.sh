inotifywait -e modify \
  '/home/olivier/projects/g4d/src/v4d/game/assets/shaders/celestialDotBackground.glsl'\
  '/home/olivier/projects/g4d/src/v4d/game/galaxy/glsl/background.glsl'

if [[ -e '/home/olivier/projects/g4d/build/debug/game/assets/shaders/celestialDotBackground.meta' ]] ; then
  echo "
  "
  '/home/olivier/projects/g4d/build/shadercompiler' '/home/olivier/projects/g4d/src/v4d/game/assets/shaders/celestialDotBackground.glsl' '/home/olivier/projects/g4d/build/debug/game/assets/shaders/celestialDotBackground.meta' '/home/olivier/projects/g4d/src' '/home/olivier/projects/g4d/src/v4d/core/utilities/graphics/shaders'
  echo "
  "
  sh -c $0 
fi
