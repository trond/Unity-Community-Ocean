This is based on TwinFox's excellent FFT water from the Unity forums 
(http://forum.unity3d.com/threads/16540-Wanted-Ocean-shader)

Known issues:
-Only works on Pro as is.
-(Somewhat improved) The water tiles don't tile particularly well with lower LODs. This works well for a stationary camera,
 but for a moving one you'd want to shift the tiles as the camera moves.
-The water tiles sometimes get culled, probably because the bounds for the mesh
 are not updated/compensating for the animated vertex offset.
-When the camera is very close to the reflection plane, the reflection looks like garbage. This
 effect is even more noticable using the skybox provided in the sample scene, because it starts
 sampling from the black area in these cases.
-If the water tiles are rotated, the reflection/refraction will not work since the reflection
 plane is hardcoded to be XZ-aligned.
-This will most likely not run at all on lower-end hardware and most likely result in
 low framerate on anything else.
-The underwater pass is now rendered even if there is no chance of the camera being under water.
 Also, the underwater pass does not clip anything above the sealevel, which is also an optimization
 that should have been there (see how the reflection/refraction passes do this). The opposite is
 true for the overwater pass.
 
Any improvements are more than welcome (and necessary :)!