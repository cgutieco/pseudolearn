# Launch Screen Assets

Estos PNG no se editan a mano ni se sustituyen desde Xcode: los escribe el generador de la aplicación
a partir de la misma geometría de marca que la app dibuja en su primer fotograma, junto con este
`Contents.json` y el color de fondo de `LaunchBackground.colorset`.

```bash
flutter test tool/generate_launch_images.dart
```
