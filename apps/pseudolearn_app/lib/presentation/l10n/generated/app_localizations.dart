import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Título principal de la aplicación
  ///
  /// In es, this message translates to:
  /// **'PseudoLearn'**
  String get appTitle;

  /// Destino de navegación al editor de código
  ///
  /// In es, this message translates to:
  /// **'Editor'**
  String get navEditor;

  /// Destino de navegación al ordinograma
  ///
  /// In es, this message translates to:
  /// **'Ordinograma'**
  String get navFlowchart;

  /// Destino de navegación a la tabla de traza
  ///
  /// In es, this message translates to:
  /// **'Prueba de escritorio'**
  String get navTrace;

  /// Destino de navegación a la base de conocimiento
  ///
  /// In es, this message translates to:
  /// **'Base de conocimiento'**
  String get navKnowledge;

  /// Destino de navegación a la biblioteca de algoritmos
  ///
  /// In es, this message translates to:
  /// **'Mis algoritmos'**
  String get navLibrary;

  /// Destino de navegación a los ajustes
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// Acción para guardar el documento actual
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get actionSave;

  /// Acción para iniciar la ejecución del programa
  ///
  /// In es, this message translates to:
  /// **'Ejecutar'**
  String get actionRun;

  /// Acción para avanzar un paso de ejecución
  ///
  /// In es, this message translates to:
  /// **'Paso a paso'**
  String get actionStep;

  /// Acción para acercar el diagrama
  ///
  /// In es, this message translates to:
  /// **'Acercar'**
  String get diagramZoomIn;

  /// Acción para alejar el diagrama
  ///
  /// In es, this message translates to:
  /// **'Alejar'**
  String get diagramZoomOut;

  /// Acción para devolver el diagrama completo a la vista
  ///
  /// In es, this message translates to:
  /// **'Encuadrar el diagrama'**
  String get diagramFitToView;

  /// Acción para detener la ejecución
  ///
  /// In es, this message translates to:
  /// **'Detener'**
  String get actionStop;

  /// Acción para ejecutar de una vez el bloque en el que está el foco
  ///
  /// In es, this message translates to:
  /// **'Saltar bloque'**
  String get actionStepOverBlock;

  /// Acción para terminar el bloque que contiene al foco y parar después de él
  ///
  /// In es, this message translates to:
  /// **'Salir del bloque'**
  String get actionStepOutOfBlock;

  /// Acción para seguir la ejecución sin parar en cada sentencia
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get actionContinue;

  /// Acción para avanzar una sola sentencia dentro de una sesión de depuración
  ///
  /// In es, this message translates to:
  /// **'Paso'**
  String get actionStepInto;

  /// Acción para abrir el diálogo de exportación
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get actionExport;

  /// Acción genérica de cancelación
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// Acción destructiva de eliminación
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get actionDelete;

  /// Acción para renombrar
  ///
  /// In es, this message translates to:
  /// **'Renombrar'**
  String get actionRename;

  /// Acción para crear un nuevo elemento
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get actionCreate;

  /// Acción para copiar contenido al portapapeles
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get actionCopy;

  /// Opción de idioma siguiendo el sistema operativo
  ///
  /// In es, this message translates to:
  /// **'Idioma del sistema'**
  String get languageSystem;

  /// Opción de idioma español
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Opción de idioma inglés
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get languageEnglish;

  /// Perfil de sintaxis en español clásico
  ///
  /// In es, this message translates to:
  /// **'Español clásico'**
  String get profileSpanish;

  /// Perfil de sintaxis en inglés
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get profileEnglish;

  /// Contador de diagnósticos con pluralización
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin problemas} =1{1 problema} other{{count} problemas}}'**
  String diagnosticsCount(int count);

  /// Título de la pantalla de biblioteca
  ///
  /// In es, this message translates to:
  /// **'Mis algoritmos'**
  String get libraryTitle;

  /// Texto del marcador de posición en la búsqueda de biblioteca
  ///
  /// In es, this message translates to:
  /// **'Buscar algoritmos...'**
  String get librarySearchPlaceholder;

  /// Texto del botón para crear un nuevo algoritmo
  ///
  /// In es, this message translates to:
  /// **'Nuevo algoritmo'**
  String get libraryNewDocument;

  /// Título del estado vacío de la biblioteca
  ///
  /// In es, this message translates to:
  /// **'Sin algoritmos aún'**
  String get libraryEmptyTitle;

  /// Descripción del estado vacío de la biblioteca
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer algoritmo para empezar a programar.'**
  String get libraryEmptyDescription;

  /// Título cuando la búsqueda no produce resultados
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get libraryEmptySearchTitle;

  /// Descripción de búsqueda sin resultados
  ///
  /// In es, this message translates to:
  /// **'No se encontraron algoritmos para \"{query}\".'**
  String libraryEmptySearchDescription(String query);

  /// Título del diálogo de nuevo documento
  ///
  /// In es, this message translates to:
  /// **'Nuevo algoritmo'**
  String get dialogNewDocTitle;

  /// Etiqueta del campo de nombre de algoritmo
  ///
  /// In es, this message translates to:
  /// **'Nombre del algoritmo'**
  String get dialogNewDocNameLabel;

  /// Etiqueta del selector de perfil de sintaxis
  ///
  /// In es, this message translates to:
  /// **'Perfil de sintaxis'**
  String get dialogNewDocProfileLabel;

  /// Título del diálogo para renombrar
  ///
  /// In es, this message translates to:
  /// **'Renombrar algoritmo'**
  String get dialogRenameDocTitle;

  /// Título del diálogo de confirmación de eliminación
  ///
  /// In es, this message translates to:
  /// **'Eliminar algoritmo'**
  String get dialogDeleteDocTitle;

  /// Mensaje de confirmación para eliminar documento
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar \"{title}\"? Esta acción no se puede deshacer.'**
  String dialogDeleteDocMessage(String title);

  /// Pestaña de edición de código
  ///
  /// In es, this message translates to:
  /// **'Editor'**
  String get tabEditor;

  /// Pestaña de diagramas, con su conmutador de notación
  ///
  /// In es, this message translates to:
  /// **'Diagramas'**
  String get tabDiagrams;

  /// Pestaña de tabla de prueba de escritorio
  ///
  /// In es, this message translates to:
  /// **'Prueba de escritorio'**
  String get tabTrace;

  /// Pestaña de exportación
  ///
  /// In es, this message translates to:
  /// **'Exportación'**
  String get tabExport;

  /// Aviso de exportación pendiente en Fase 0
  ///
  /// In es, this message translates to:
  /// **'Disponible cuando el motor de exportación esté listo'**
  String get exportComingSoon;

  /// Título del panel de salida
  ///
  /// In es, this message translates to:
  /// **'Salida del programa'**
  String get outputPanelTitle;

  /// Contador de líneas de salida con pluralización
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{0 líneas} =1{1 línea} other{{count} líneas}}'**
  String outputLinesCount(int count);

  /// Aviso de que la salida pertenece a una ejecución previa
  ///
  /// In es, this message translates to:
  /// **'de la ejecución anterior'**
  String get outputPreviousExecution;

  /// Mensaje cuando no hay líneas de salida
  ///
  /// In es, this message translates to:
  /// **'La salida del programa aparecerá aquí.'**
  String get outputEmpty;

  /// Contador de pasos del programa
  ///
  /// In es, this message translates to:
  /// **'Paso {current} de {max}'**
  String stepCounter(int current, int max);

  /// Estado del pie cuando no hay ninguna ejecución en curso
  ///
  /// In es, this message translates to:
  /// **'Sin ejecución'**
  String get executionStatusIdle;

  /// Estado del pie cuando la ejecución está pausada sobre una línea
  ///
  /// In es, this message translates to:
  /// **'Pausado en la línea {line}'**
  String executionStatusPaused(int line);

  /// Estado del pie mientras la ejecución avanza sin pausas
  ///
  /// In es, this message translates to:
  /// **'Ejecutando'**
  String get executionStatusRunning;

  /// Estado del pie cuando la ejecución espera una entrada
  ///
  /// In es, this message translates to:
  /// **'Esperando un dato'**
  String get executionStatusAwaitingInput;

  /// Estado del pie cuando el programa terminó correctamente
  ///
  /// In es, this message translates to:
  /// **'Ejecución terminada'**
  String get executionStatusFinished;

  /// Marca de la fila de la tabla cuya sentencia todavía no terminó
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get traceRowOpen;

  /// Contador de sentencias ejecutadas en el paso a paso
  ///
  /// In es, this message translates to:
  /// **'Sentencia {current}'**
  String statementCounter(int current);

  /// Tira de seguimiento cuando el paso no cambió ninguna variable
  ///
  /// In es, this message translates to:
  /// **'Sin cambios en este paso'**
  String get trackingStripEmpty;

  /// Rótulo de la tira de seguimiento que precede a las variables que cambiaron
  ///
  /// In es, this message translates to:
  /// **'Cambió'**
  String get trackingStripLabel;

  /// Conmutador que promueve la pestaña activa a panel acompañante
  ///
  /// In es, this message translates to:
  /// **'Acompañar'**
  String get companionToggle;

  /// Rótulo de la pestaña que muestra el programa en Python o Rust
  ///
  /// In es, this message translates to:
  /// **'Código equivalente'**
  String get tabEquivalentCode;

  /// Título del banner de advertencia cuando se alcanza el límite de pasos
  ///
  /// In es, this message translates to:
  /// **'Tope de pasos alcanzado'**
  String get bannerStepLimitTitle;

  /// Cuerpo del banner de advertencia de límite de pasos
  ///
  /// In es, this message translates to:
  /// **'El programa alcanzó el límite de pasos sin terminar. Revisa posibles bucles infinitos.'**
  String get bannerStepLimitBody;

  /// Título del banner de éxito al concluir el programa
  ///
  /// In es, this message translates to:
  /// **'Ejecución finalizada con éxito'**
  String get bannerSuccessTitle;

  /// Título del banner de error durante la ejecución
  ///
  /// In es, this message translates to:
  /// **'Ejecución detenida'**
  String get bannerErrorTitle;

  /// Rótulo del control que retira el banner de estado de ejecución
  ///
  /// In es, this message translates to:
  /// **'Descartar aviso'**
  String get bannerDismiss;

  /// Título del diálogo de entrada interactiva de datos
  ///
  /// In es, this message translates to:
  /// **'Entrada de datos'**
  String get inputDialogTitle;

  /// Mensaje de solicitud de dato
  ///
  /// In es, this message translates to:
  /// **'Ingresa un valor para continuar:'**
  String get inputDialogPrompt;

  /// Botón para enviar el dato ingresado
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get inputDialogSubmit;

  /// Mensaje en el panel de diagnósticos cuando no hay errores
  ///
  /// In es, this message translates to:
  /// **'Sin problemas detectados'**
  String get diagnosticsEmpty;

  /// Mensaje del ordinograma cuando no hay AST válido
  ///
  /// In es, this message translates to:
  /// **'El ordinograma estará disponible cuando el código no tenga errores.'**
  String get flowchartEmpty;

  /// Mensaje del estructograma cuando no hay AST válido
  ///
  /// In es, this message translates to:
  /// **'El estructograma estará disponible cuando el código no tenga errores.'**
  String get structogramEmpty;

  /// Opción de notación de ordinograma en el conmutador del lienzo
  ///
  /// In es, this message translates to:
  /// **'Ordinograma'**
  String get diagramNotationFlowchart;

  /// Opción de notación de diagrama de clases en el conmutador del lienzo
  ///
  /// In es, this message translates to:
  /// **'Diagrama de clases'**
  String get diagramNotationClassDiagram;

  /// Mensaje del diagrama de clases cuando no hay AST válido
  ///
  /// In es, this message translates to:
  /// **'El diagrama de clases estará disponible cuando el código no tenga errores.'**
  String get classDiagramEmpty;

  /// Mensaje del diagrama de clases cuando el documento analiza pero no declara clases
  ///
  /// In es, this message translates to:
  /// **'Este documento no declara ninguna clase.'**
  String get classDiagramNoClasses;

  /// Opción de notación de estructograma en el conmutador del lienzo
  ///
  /// In es, this message translates to:
  /// **'Estructograma'**
  String get diagramNotationStructogram;

  /// Mensaje de la tabla de traza cuando no hay ejecución iniciada
  ///
  /// In es, this message translates to:
  /// **'Inicia la ejecución para ver la prueba de escritorio.'**
  String get traceEmpty;

  /// Encabezado de columna de paso en tabla de traza
  ///
  /// In es, this message translates to:
  /// **'Paso'**
  String get traceStepHeader;

  /// Encabezado de columna de línea en tabla de traza
  ///
  /// In es, this message translates to:
  /// **'Línea'**
  String get traceLineHeader;

  /// Encabezado de columna de ámbito en tabla de traza
  ///
  /// In es, this message translates to:
  /// **'Ámbito'**
  String get traceScopeHeader;

  /// Título de la pantalla de base de conocimiento
  ///
  /// In es, this message translates to:
  /// **'Base de conocimiento'**
  String get knowledgeTitle;

  /// Texto del buscador en base de conocimiento
  ///
  /// In es, this message translates to:
  /// **'Buscar en la base de conocimiento...'**
  String get knowledgeSearchPlaceholder;

  /// Nombre de la sección de ruta de aprendizaje
  ///
  /// In es, this message translates to:
  /// **'Ruta'**
  String get knowledgeSectionRoute;

  /// Nombre de la sección de especificación
  ///
  /// In es, this message translates to:
  /// **'Especificación'**
  String get knowledgeSectionSpecification;

  /// Nombre de la sección de ejercicios
  ///
  /// In es, this message translates to:
  /// **'Ejercicios'**
  String get knowledgeSectionExercises;

  /// Encabezado del primer tramo de la ruta de aprendizaje
  ///
  /// In es, this message translates to:
  /// **'Tramo A · Fundamentos'**
  String get knowledgeRouteTrackFoundations;

  /// Encabezado del segundo tramo de la ruta de aprendizaje
  ///
  /// In es, this message translates to:
  /// **'Tramo B · Imperativo y estructurado'**
  String get knowledgeRouteTrackImperative;

  /// Encabezado del tercer tramo de la ruta de aprendizaje
  ///
  /// In es, this message translates to:
  /// **'Tramo C · Orientación a objetos'**
  String get knowledgeRouteTrackObjectOriented;

  /// Marca de un módulo ya visitado en la ruta de aprendizaje
  ///
  /// In es, this message translates to:
  /// **'Visitado'**
  String get knowledgeModuleVisited;

  /// Etiqueta para tipo módulo
  ///
  /// In es, this message translates to:
  /// **'Módulo'**
  String get knowledgeTypeModule;

  /// Etiqueta para tipo sección de especificación
  ///
  /// In es, this message translates to:
  /// **'Especificación'**
  String get knowledgeTypeSpecification;

  /// Etiqueta para tipo actividad de predicción
  ///
  /// In es, this message translates to:
  /// **'Predicción'**
  String get knowledgeTypePrediction;

  /// Etiqueta para tipo ilustración
  ///
  /// In es, this message translates to:
  /// **'Ilustración'**
  String get knowledgeTypeIllustration;

  /// Etiqueta para tipo ejemplo
  ///
  /// In es, this message translates to:
  /// **'Ejemplo'**
  String get knowledgeTypeExample;

  /// Etiqueta para tipo ejercicio
  ///
  /// In es, this message translates to:
  /// **'Ejercicio'**
  String get knowledgeTypeExercise;

  /// Etiqueta para tipo referencia
  ///
  /// In es, this message translates to:
  /// **'Referencia'**
  String get knowledgeTypeReference;

  /// Título cuando no hay contenido en la base de conocimiento
  ///
  /// In es, this message translates to:
  /// **'Sin contenido'**
  String get knowledgeEmptyTitle;

  /// Descripción cuando la base de conocimiento está vacía
  ///
  /// In es, this message translates to:
  /// **'No hay contenido disponible en la base de conocimiento.'**
  String get knowledgeEmptyDescription;

  /// Título cuando la búsqueda o filtro no arroja resultados
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get knowledgeEmptySearchTitle;

  /// Descripción cuando la búsqueda no encuentra coincidencias
  ///
  /// In es, this message translates to:
  /// **'No se encontraron elementos para \"{query}\".'**
  String knowledgeEmptySearchDescription(String query);

  /// Título en caso de error al cargar el contenido
  ///
  /// In es, this message translates to:
  /// **'Error de contenido'**
  String get knowledgeErrorTitle;

  /// Mensaje en caso de error al cargar el contenido
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la base de conocimiento.'**
  String get knowledgeErrorDescription;

  /// Botón para reintentar la carga
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get knowledgeActionRetry;

  /// Botón para abrir un ejemplo en un nuevo documento
  ///
  /// In es, this message translates to:
  /// **'Abrir en un documento nuevo'**
  String get knowledgeDetailOpenInNewDocument;

  /// Tooltip de confirmación de copiado
  ///
  /// In es, this message translates to:
  /// **'Copiado'**
  String get knowledgeDetailCopied;

  /// Título cuando no se encuentra el detalle de una entrada
  ///
  /// In es, this message translates to:
  /// **'Elemento no encontrado'**
  String get knowledgeDetailNotFoundTitle;

  /// Descripción cuando no se encuentra la entrada
  ///
  /// In es, this message translates to:
  /// **'El elemento solicitado no existe en la base de conocimiento.'**
  String get knowledgeDetailNotFoundDescription;

  /// Botón para regresar al listado de conocimiento
  ///
  /// In es, this message translates to:
  /// **'Volver a la base de conocimiento'**
  String get knowledgeDetailBack;

  /// Etiqueta para la lista de encabezados navegables
  ///
  /// In es, this message translates to:
  /// **'Secciones'**
  String get knowledgeDetailSections;

  /// Encabezado de la parte 1 del módulo
  ///
  /// In es, this message translates to:
  /// **'Pregunta'**
  String get knowledgeModulePartQuestion;

  /// Encabezado de la parte 2 del módulo
  ///
  /// In es, this message translates to:
  /// **'Qué cambia en tu modelo de la máquina'**
  String get knowledgeModulePartMachineModel;

  /// Encabezado de la parte 3 del módulo
  ///
  /// In es, this message translates to:
  /// **'Desarrollo'**
  String get knowledgeModulePartDevelopment;

  /// Encabezado de la parte 4 del módulo
  ///
  /// In es, this message translates to:
  /// **'Predice y ejecuta'**
  String get knowledgeModulePartPrediction;

  /// Encabezado de la parte 5 del módulo
  ///
  /// In es, this message translates to:
  /// **'Errores frecuentes'**
  String get knowledgeModulePartCommonErrors;

  /// Encabezado de la parte 6 del módulo
  ///
  /// In es, this message translates to:
  /// **'En la especificación'**
  String get knowledgeModulePartSpecification;

  /// Encabezado de la parte 7 del módulo
  ///
  /// In es, this message translates to:
  /// **'Ejercicios'**
  String get knowledgeModulePartExercises;

  /// Botón para ejecutar y contrastar la predicción
  ///
  /// In es, this message translates to:
  /// **'Ejecutar'**
  String get knowledgePredictionCheck;

  /// Botón para reintentar la actividad de predicción
  ///
  /// In es, this message translates to:
  /// **'Intentar de nuevo'**
  String get knowledgePredictionRetry;

  /// Mensaje cuando la predicción coincide con el valor de la máquina
  ///
  /// In es, this message translates to:
  /// **'Coincide'**
  String get knowledgePredictionMatch;

  /// Mensaje cuando la predicción no coincide con el valor de la máquina
  ///
  /// In es, this message translates to:
  /// **'Esperabas {predicted}, la máquina tiene {actual}'**
  String knowledgePredictionMismatch(String predicted, String actual);

  /// Placeholder del campo de texto de predicción
  ///
  /// In es, this message translates to:
  /// **'Escribe tu predicción'**
  String get knowledgePredictionEmptyHint;

  /// Mensaje de error cuando la ejecución termina antes del paso esperado
  ///
  /// In es, this message translates to:
  /// **'El programa no llega al paso {step}'**
  String knowledgePredictionNotReached(int step);

  /// Botón para volver al módulo que referenció la sección de especificación
  ///
  /// In es, this message translates to:
  /// **'Volver al módulo {moduleTitle}'**
  String knowledgeSpecReturnToModule(String moduleTitle);

  /// Nombre del nivel 1 de dificultad
  ///
  /// In es, this message translates to:
  /// **'Nivel 1 · Reproducir'**
  String get exerciseLevel1;

  /// Nombre del nivel 2 de dificultad
  ///
  /// In es, this message translates to:
  /// **'Nivel 2 · Componer'**
  String get exerciseLevel2;

  /// Nombre del nivel 3 de dificultad
  ///
  /// In es, this message translates to:
  /// **'Nivel 3 · Diseñar'**
  String get exerciseLevel3;

  /// Etiqueta corta del nivel 1
  ///
  /// In es, this message translates to:
  /// **'Nivel 1'**
  String get exerciseLevelShort1;

  /// Etiqueta corta del nivel 2
  ///
  /// In es, this message translates to:
  /// **'Nivel 2'**
  String get exerciseLevelShort2;

  /// Etiqueta corta del nivel 3
  ///
  /// In es, this message translates to:
  /// **'Nivel 3'**
  String get exerciseLevelShort3;

  /// Tipo de ejercicio: predecir
  ///
  /// In es, this message translates to:
  /// **'Predecir'**
  String get exerciseKindPredict;

  /// Tipo de ejercicio: completar
  ///
  /// In es, this message translates to:
  /// **'Completar'**
  String get exerciseKindComplete;

  /// Tipo de ejercicio: modificar
  ///
  /// In es, this message translates to:
  /// **'Modificar'**
  String get exerciseKindModify;

  /// Tipo de ejercicio: crear
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get exerciseKindCreate;

  /// Insignia que indica que el ejercicio ya fue completado con éxito
  ///
  /// In es, this message translates to:
  /// **'Superado'**
  String get exerciseCompletedBadge;

  /// Etiqueta de filtro por nivel
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get exerciseFilterLevel;

  /// Etiqueta de filtro por módulo
  ///
  /// In es, this message translates to:
  /// **'Módulo'**
  String get exerciseFilterModule;

  /// Etiqueta de filtro por construcción requerida
  ///
  /// In es, this message translates to:
  /// **'Construcción'**
  String get exerciseFilterConstruct;

  /// Opción para no filtrar por nivel
  ///
  /// In es, this message translates to:
  /// **'Todos los niveles'**
  String get exerciseFilterAllLevels;

  /// Opción para no filtrar por construcción
  ///
  /// In es, this message translates to:
  /// **'Todas las construcciones'**
  String get exerciseFilterAllConstructs;

  /// Nombre de la construcción condicional Si/Sino
  ///
  /// In es, this message translates to:
  /// **'Condicional'**
  String get exerciseConstructConditional;

  /// Nombre de la construcción selección múltiple Según
  ///
  /// In es, this message translates to:
  /// **'Selección múltiple'**
  String get exerciseConstructMultipleSelection;

  /// Nombre del bucle Mientras
  ///
  /// In es, this message translates to:
  /// **'Bucle condicional'**
  String get exerciseConstructConditionalLoop;

  /// Nombre del bucle Repetir-Hasta que
  ///
  /// In es, this message translates to:
  /// **'Bucle posterior'**
  String get exerciseConstructPostConditionalLoop;

  /// Nombre del bucle Para
  ///
  /// In es, this message translates to:
  /// **'Bucle contado'**
  String get exerciseConstructCountedLoop;

  /// Nombre de la construcción de arreglos / Dimension
  ///
  /// In es, this message translates to:
  /// **'Arreglos'**
  String get exerciseConstructArrayDeclaration;

  /// Nombre de la construcción de funciones y procedimientos
  ///
  /// In es, this message translates to:
  /// **'Subprogramas'**
  String get exerciseConstructSubprogram;

  /// Nombre de la construcción de clases y objetos
  ///
  /// In es, this message translates to:
  /// **'Clases'**
  String get exerciseConstructClassDeclaration;

  /// Botón para restablecer los filtros de ejercicios
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get exerciseClearFilters;

  /// Título cuando no hay ejercicios en el catálogo
  ///
  /// In es, this message translates to:
  /// **'Sin ejercicios'**
  String get exerciseBankEmptyTitle;

  /// Descripción cuando el catálogo de ejercicios está vacío
  ///
  /// In es, this message translates to:
  /// **'No hay ejercicios disponibles en la base de conocimiento.'**
  String get exerciseBankEmptyDescription;

  /// Título cuando los filtros no coinciden con ningún ejercicio
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get exerciseBankEmptyFilterTitle;

  /// Descripción cuando los filtros de ejercicios no arrojan resultados
  ///
  /// In es, this message translates to:
  /// **'Ningún ejercicio coincide con los filtros o la búsqueda seleccionada.'**
  String get exerciseBankEmptyFilterDescription;

  /// Título de la franja de ejercicio en el editor
  ///
  /// In es, this message translates to:
  /// **'Ejercicio: {title}'**
  String exerciseStripTitle(String title);

  /// Etiqueta semántica para contraer la franja de ejercicio
  ///
  /// In es, this message translates to:
  /// **'Contraer franja de ejercicio'**
  String get exerciseStripCollapse;

  /// Etiqueta semántica para expandir la franja de ejercicio
  ///
  /// In es, this message translates to:
  /// **'Expandir franja de ejercicio'**
  String get exerciseStripExpand;

  /// Etiqueta del botón para comprobar la solución del ejercicio
  ///
  /// In es, this message translates to:
  /// **'Comprobar'**
  String get exerciseActionCheck;

  /// Texto mostrado mientras se comprueba la solución
  ///
  /// In es, this message translates to:
  /// **'Comprobando...'**
  String get exerciseChecking;

  /// Resultado pedagógico de casos superados
  ///
  /// In es, this message translates to:
  /// **'Cumple {passed} de {total} casos'**
  String exercisePassedCount(int passed, int total);

  /// Aviso cuando se superan todos los casos de prueba
  ///
  /// In es, this message translates to:
  /// **'¡Cumple todos los casos de prueba!'**
  String get exerciseAllCasesPassed;

  /// Encabezado para revelar el primer caso oculto fallido
  ///
  /// In es, this message translates to:
  /// **'Primer caso oculto fallido:'**
  String get exerciseHiddenFailureTitle;

  /// Entrada del caso oculto fallido
  ///
  /// In es, this message translates to:
  /// **'Entrada: {inputs}'**
  String exerciseHiddenInputs(String inputs);

  /// Salida esperada del caso oculto fallido
  ///
  /// In es, this message translates to:
  /// **'Salida esperada: {expected}'**
  String exerciseHiddenExpected(String expected);

  /// Salida obtenida del caso oculto fallido
  ///
  /// In es, this message translates to:
  /// **'Salida obtenida: {actual}'**
  String exerciseHiddenActual(String actual);

  /// Mensaje cuando el programa no analiza sintácticamente
  ///
  /// In es, this message translates to:
  /// **'El programa contiene errores de sintaxis y no puede comprobarse.'**
  String get exerciseOutcomeParseError;

  /// Mensaje cuando la ejecución se detuvo prematuramente
  ///
  /// In es, this message translates to:
  /// **'La ejecución se detuvo de forma anómala.'**
  String get exerciseOutcomeHalted;

  /// Mensaje cuando la ejecución alcanzó el límite de pasos
  ///
  /// In es, this message translates to:
  /// **'Se agotó el límite de pasos (posible bucle infinito).'**
  String get exerciseOutcomeStepLimit;

  /// Mensaje cuando se agotaron las entradas provistas
  ///
  /// In es, this message translates to:
  /// **'El programa solicitó más entradas de las previstas.'**
  String get exerciseOutcomeInputExhausted;

  /// Título cuando el ejercicio vinculado no existe
  ///
  /// In es, this message translates to:
  /// **'Ejercicio no disponible'**
  String get exerciseNotFoundTitle;

  /// Aviso cuando el ejercicio vinculado no existe en el catálogo
  ///
  /// In es, this message translates to:
  /// **'El ejercicio vinculado ({id}) no existe en el catálogo. Puedes editar y ejecutar este documento con normalidad.'**
  String exerciseNotFoundInCatalog(String id);

  /// Título de la sección de casos de prueba visibles
  ///
  /// In es, this message translates to:
  /// **'Casos de prueba visibles:'**
  String get exerciseVisibleCasesTitle;

  /// Entradas de un caso de prueba visible
  ///
  /// In es, this message translates to:
  /// **'Entrada: {inputs}'**
  String exerciseCaseInputsLabel(String inputs);

  /// Salidas de un caso de prueba visible
  ///
  /// In es, this message translates to:
  /// **'Salida esperada: {outputs}'**
  String exerciseCaseOutputsLabel(String outputs);

  /// Mensaje de aserción estructural no cumplida
  ///
  /// In es, this message translates to:
  /// **'Falta la restricción: {requirement}'**
  String exerciseUnmetAssertion(String requirement);

  /// Texto del indicador de pasos
  ///
  /// In es, this message translates to:
  /// **'Paso {current} de {total}'**
  String onboardingStepOf(int current, int total);

  /// Título del paso de bienvenida
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a PseudoLearn'**
  String get onboardingWelcomeTitle;

  /// Subtítulo del paso de bienvenida
  ///
  /// In es, this message translates to:
  /// **'Escribe pseudocódigo y mira cómo se ejecuta: diagramas, prueba de escritorio y salida, todo a la vez.'**
  String get onboardingWelcomeSubtitle;

  /// Primer punto de valor del paso de bienvenida
  ///
  /// In es, this message translates to:
  /// **'Un motor que ejecuta de verdad, instrucción a instrucción'**
  String get onboardingWelcomeHighlightEngine;

  /// Segundo punto de valor del paso de bienvenida
  ///
  /// In es, this message translates to:
  /// **'Ordinograma, estructograma y diagrama de clases del mismo programa'**
  String get onboardingWelcomeHighlightDiagrams;

  /// Tercer punto de valor del paso de bienvenida
  ///
  /// In es, this message translates to:
  /// **'Una ruta de aprendizaje con ejercicios que se comprueban solos'**
  String get onboardingWelcomeHighlightRoute;

  /// Título del paso de laboratorio
  ///
  /// In es, this message translates to:
  /// **'El laboratorio en vivo'**
  String get onboardingLabTitle;

  /// Subtítulo del paso de laboratorio
  ///
  /// In es, this message translates to:
  /// **'Pulsa «Paso a paso» y observa cómo reaccionan a la vez el código, los diagramas, la prueba de escritorio y la salida.'**
  String get onboardingLabSubtitle;

  /// Rótulo de la tarjeta de enunciado del laboratorio
  ///
  /// In es, this message translates to:
  /// **'La casuística'**
  String get onboardingLabBriefTitle;

  /// Enunciado de la casuística que resuelve el programa de demostración
  ///
  /// In es, this message translates to:
  /// **'Un termómetro empieza en 30 grados y se enfría de tres en tres hasta llegar a los 24 grados de confort. Cuenta cuántas veces se enfrió y anuncia el resultado.'**
  String get onboardingLabBriefStatement;

  /// Aviso de que el laboratorio no permite editar
  ///
  /// In es, this message translates to:
  /// **'Vista de solo lectura: aquí se observa, no se edita.'**
  String get onboardingLabReadOnly;

  /// Rótulo de la superficie de diagramas del laboratorio
  ///
  /// In es, this message translates to:
  /// **'Diagramas'**
  String get onboardingLabSurfaceDiagrams;

  /// Rótulo de la superficie de prueba de escritorio del laboratorio
  ///
  /// In es, this message translates to:
  /// **'Prueba de escritorio'**
  String get onboardingLabSurfaceTrace;

  /// Rótulo de la superficie de salida del laboratorio
  ///
  /// In es, this message translates to:
  /// **'Salida'**
  String get onboardingLabSurfaceOutput;

  /// Botón para volver a empezar la demostración
  ///
  /// In es, this message translates to:
  /// **'Reiniciar'**
  String get onboardingLabActionRestart;

  /// Estado del laboratorio antes del primer paso
  ///
  /// In es, this message translates to:
  /// **'Listo para ejecutar la primera instrucción.'**
  String get onboardingLabStatusReady;

  /// Estado del laboratorio durante la ejecución
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 instrucción ejecutada} other{{count} instrucciones ejecutadas}}'**
  String onboardingLabStatusStepping(int count);

  /// Estado del laboratorio cuando el programa termina
  ///
  /// In es, this message translates to:
  /// **'Programa terminado. Reinicia para volver a verlo.'**
  String get onboardingLabStatusFinished;

  /// Aviso cuando el programa de demostración no se puede cargar
  ///
  /// In es, this message translates to:
  /// **'La demostración no está disponible ahora mismo. Puedes continuar sin ella.'**
  String get onboardingLabUnavailable;

  /// Título del paso de base de conocimiento
  ///
  /// In es, this message translates to:
  /// **'Tu base de conocimiento'**
  String get onboardingKnowledgeTitle;

  /// Subtítulo del paso de base de conocimiento
  ///
  /// In es, this message translates to:
  /// **'No estás solo frente a la hoja en blanco: hay una ruta, una especificación y un banco de ejercicios esperándote.'**
  String get onboardingKnowledgeSubtitle;

  /// Título de la tarjeta de ruta de aprendizaje
  ///
  /// In es, this message translates to:
  /// **'Ruta personalizada'**
  String get onboardingKnowledgeRouteTitle;

  /// Descripción de la tarjeta de ruta de aprendizaje
  ///
  /// In es, this message translates to:
  /// **'Tres tramos encadenados que llevan desde los fundamentos hasta la programación orientada a objetos con pseudocódigo.'**
  String get onboardingKnowledgeRouteDescription;

  /// Nombre del primer tramo de la ruta
  ///
  /// In es, this message translates to:
  /// **'Fundamentos'**
  String get onboardingKnowledgeTrackFoundations;

  /// Nombre del segundo tramo de la ruta
  ///
  /// In es, this message translates to:
  /// **'Programación imperativa'**
  String get onboardingKnowledgeTrackImperative;

  /// Nombre del tercer tramo de la ruta
  ///
  /// In es, this message translates to:
  /// **'Objetos con pseudocódigo'**
  String get onboardingKnowledgeTrackObjectOriented;

  /// Recuento de módulos de un tramo
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 módulo} other{{count} módulos}}'**
  String onboardingKnowledgeModuleCount(int count);

  /// Título de la tarjeta de especificación
  ///
  /// In es, this message translates to:
  /// **'Especificación de sintaxis'**
  String get onboardingKnowledgeSpecificationTitle;

  /// Descripción de la tarjeta de especificación
  ///
  /// In es, this message translates to:
  /// **'Cada construcción del lenguaje, con su forma exacta y sus ejemplos ejecutables.'**
  String get onboardingKnowledgeSpecificationDescription;

  /// Recuento de secciones de especificación
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 sección} other{{count} secciones}}'**
  String onboardingKnowledgeSpecificationCount(int count);

  /// Título de la tarjeta de banco de ejercicios
  ///
  /// In es, this message translates to:
  /// **'Banco de ejercicios'**
  String get onboardingKnowledgeExercisesTitle;

  /// Descripción de la tarjeta de banco de ejercicios
  ///
  /// In es, this message translates to:
  /// **'Enunciados con casos de prueba que la aplicación comprueba por ti, ordenados por dificultad.'**
  String get onboardingKnowledgeExercisesDescription;

  /// Recuento total de ejercicios
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 ejercicio} other{{count} ejercicios}}'**
  String onboardingKnowledgeExerciseCount(int count);

  /// Recuento de ejercicios de un nivel de dificultad
  ///
  /// In es, this message translates to:
  /// **'Nivel {level}: {count}'**
  String onboardingKnowledgeLevelCount(int level, int count);

  /// Aviso cuando el catálogo de conocimiento no carga
  ///
  /// In es, this message translates to:
  /// **'El catálogo no se pudo leer ahora mismo. Estará disponible dentro de la aplicación.'**
  String get onboardingKnowledgeUnavailable;

  /// Título del paso de cierre
  ///
  /// In es, this message translates to:
  /// **'¡Todo listo para empezar!'**
  String get onboardingCompletionTitle;

  /// Subtítulo del paso de cierre
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer algoritmo desde cero, o entra por la ruta de aprendizaje si prefieres que te guíen.'**
  String get onboardingCompletionSubtitle;

  /// Botón primario para crear el primer documento desde el onboarding
  ///
  /// In es, this message translates to:
  /// **'Crear mi primer documento'**
  String get onboardingActionCreateFirst;

  /// Botón secundario para abrir la ruta de aprendizaje desde el onboarding
  ///
  /// In es, this message translates to:
  /// **'Entrar en la ruta de aprendizaje'**
  String get onboardingActionExploreRoute;

  /// Botón genérico para avanzar en onboarding
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get onboardingActionNext;

  /// Botón genérico para retroceder en onboarding
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get onboardingActionBack;

  /// Botón para saltar la introducción
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get onboardingActionSkip;

  /// Título principal de la pantalla de ajustes
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// Sección general de ajustes
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// Sección de información en ajustes
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get settingsSectionInformation;

  /// Opción de idioma de la interfaz
  ///
  /// In es, this message translates to:
  /// **'Idioma de la interfaz'**
  String get settingsLanguage;

  /// Aviso de que el idioma de interfaz es independiente del de los documentos
  ///
  /// In es, this message translates to:
  /// **'No cambia el vocabulario de tus documentos'**
  String get settingsLanguageNotice;

  /// Opción de tema visual
  ///
  /// In es, this message translates to:
  /// **'Tema visual'**
  String get settingsTheme;

  /// Opción de tema según el sistema
  ///
  /// In es, this message translates to:
  /// **'Tema del sistema'**
  String get settingsThemeSystem;

  /// Opción de tema claro
  ///
  /// In es, this message translates to:
  /// **'Tema claro'**
  String get settingsThemeLight;

  /// Opción de tema oscuro
  ///
  /// In es, this message translates to:
  /// **'Tema oscuro'**
  String get settingsThemeDark;

  /// Opción para reiniciar la introducción interactiva
  ///
  /// In es, this message translates to:
  /// **'Ver la introducción de nuevo'**
  String get settingsRestartOnboarding;

  /// Opción de contacto y soporte
  ///
  /// In es, this message translates to:
  /// **'Contacto y soporte'**
  String get settingsContact;

  /// Versión de la aplicación
  ///
  /// In es, this message translates to:
  /// **'v{version}'**
  String settingsVersion(String version);

  /// Etiqueta del botón de volver en una subpantalla de ajustes
  ///
  /// In es, this message translates to:
  /// **'Volver a Ajustes'**
  String get settingsBack;

  /// Rótulo del grupo que explica un ajuste
  ///
  /// In es, this message translates to:
  /// **'Sobre este ajuste'**
  String get settingsAbout;

  /// Rótulo del grupo de opciones de idioma
  ///
  /// In es, this message translates to:
  /// **'Idiomas disponibles'**
  String get settingsLanguageOptions;

  /// Rótulo del grupo de opciones de tema
  ///
  /// In es, this message translates to:
  /// **'Temas disponibles'**
  String get settingsThemeOptions;

  /// Aviso de qué hace la opción de tema del sistema
  ///
  /// In es, this message translates to:
  /// **'«Tema del sistema» sigue la apariencia clara u oscura de tu equipo'**
  String get settingsThemeNotice;

  /// Opción de seguimiento del paso activo en los diagramas
  ///
  /// In es, this message translates to:
  /// **'Zoom asistido en diagramas'**
  String get settingsDiagramAssist;

  /// Rótulo del grupo de opciones del zoom asistido
  ///
  /// In es, this message translates to:
  /// **'Comportamiento al ejecutar paso a paso'**
  String get settingsDiagramAssistOptions;

  /// Opción que activa el seguimiento del paso activo
  ///
  /// In es, this message translates to:
  /// **'Seguir el paso activo'**
  String get settingsDiagramAssistOn;

  /// Opción que desactiva el seguimiento del paso activo
  ///
  /// In es, this message translates to:
  /// **'No mover el diagrama'**
  String get settingsDiagramAssistOff;

  /// Aviso de qué hace el seguimiento del paso activo
  ///
  /// In es, this message translates to:
  /// **'Con el seguimiento activo, el diagrama se acerca al bloque en ejecución y se desplaza hasta el siguiente sin saltos'**
  String get settingsDiagramAssistNotice;

  /// Título de la pantalla de contacto
  ///
  /// In es, this message translates to:
  /// **'Contacto y soporte'**
  String get settingsContactTitle;

  /// Mensaje cuando no hay información de contacto
  ///
  /// In es, this message translates to:
  /// **'No hay información de contacto disponible.'**
  String get settingsContactEmpty;

  /// Título de la tarjeta de consejos para reporte de problemas
  ///
  /// In es, this message translates to:
  /// **'Consejos para reportar incidencias'**
  String get settingsContactTipsTitle;

  /// Descripción de la tarjeta de consejos para reporte de problemas
  ///
  /// In es, this message translates to:
  /// **'Al escribirnos sobre un problema técnico, describe los pasos para reproducirlo e incluye el fragmento de pseudocódigo afectado para ayudarte con mayor rapidez.'**
  String get settingsContactTipsBody;

  /// Nombre de la opción de lenguaje Python
  ///
  /// In es, this message translates to:
  /// **'Python'**
  String get targetLanguagePython;

  /// Nombre de la opción de lenguaje Rust
  ///
  /// In es, this message translates to:
  /// **'Rust'**
  String get targetLanguageRust;

  /// Título de estado de error de análisis en exportación
  ///
  /// In es, this message translates to:
  /// **'Programa con errores'**
  String get exportAnalysisErrorTitle;

  /// Descripción de estado de error de análisis en exportación
  ///
  /// In es, this message translates to:
  /// **'Corrige los errores en el editor para ver el código exportado.'**
  String get exportAnalysisErrorDescription;

  /// Tooltip del botón de copiar en reposo
  ///
  /// In es, this message translates to:
  /// **'Copiar código'**
  String get exportCopyTooltip;

  /// Tooltip del botón de copiar tras confirmación
  ///
  /// In es, this message translates to:
  /// **'¡Copiado!'**
  String get exportCopiedTooltip;

  /// Descripción cuando el código fuente está vacío en exportación
  ///
  /// In es, this message translates to:
  /// **'Escribe o abre un algoritmo para ver su traducción.'**
  String get exportEmptySourceDescription;

  /// Título de la sección de notas de exportación
  ///
  /// In es, this message translates to:
  /// **'Notas de exportación'**
  String get exportNotesTitle;

  /// Accessible label for the per-document options menu
  ///
  /// In es, this message translates to:
  /// **'Opciones del documento'**
  String get libraryDocumentOptions;

  /// Etiqueta de la insignia de severidad de error
  ///
  /// In es, this message translates to:
  /// **'ERROR'**
  String get severityError;

  /// Etiqueta de la insignia de severidad de aviso
  ///
  /// In es, this message translates to:
  /// **'AVISO'**
  String get severityWarning;

  /// Etiqueta de la insignia de severidad informativa
  ///
  /// In es, this message translates to:
  /// **'INFO'**
  String get severityInfo;

  /// Etiqueta de la insignia de severidad de pista
  ///
  /// In es, this message translates to:
  /// **'PISTA'**
  String get severityHint;

  /// Etiqueta de la insignia de severidad de éxito
  ///
  /// In es, this message translates to:
  /// **'ÉXITO'**
  String get severitySuccess;

  /// Error de validación de un nombre vacío
  ///
  /// In es, this message translates to:
  /// **'El nombre no puede estar vacío'**
  String get validationNameEmpty;

  /// Error de validación cuando ya existe un documento con el mismo nombre
  ///
  /// In es, this message translates to:
  /// **'Ya existe un documento con este nombre'**
  String get validationNameDuplicate;

  /// Mensaje por defecto cuando la ejecución se detiene sin motivo propio
  ///
  /// In es, this message translates to:
  /// **'Error en tiempo de ejecución'**
  String get executionRuntimeError;

  /// Descripción accesible de la ilustración de cajas de memoria
  ///
  /// In es, this message translates to:
  /// **'Ilustración: tres casillas de memoria, cada una con su nombre encima y su valor dentro.'**
  String get illustrationMemoryBoxesSemanticLabel;

  /// Nombre de la primera casilla de memoria de la ilustración
  ///
  /// In es, this message translates to:
  /// **'contador'**
  String get illustrationMemoryBoxesVariable1;

  /// Valor de la primera casilla de memoria de la ilustración
  ///
  /// In es, this message translates to:
  /// **'3'**
  String get illustrationMemoryBoxesValue1;

  /// Nombre de la segunda casilla de memoria de la ilustración
  ///
  /// In es, this message translates to:
  /// **'total'**
  String get illustrationMemoryBoxesVariable2;

  /// Valor de la segunda casilla de memoria de la ilustración
  ///
  /// In es, this message translates to:
  /// **'12.5'**
  String get illustrationMemoryBoxesValue2;

  /// Nombre de la tercera casilla de memoria de la ilustración
  ///
  /// In es, this message translates to:
  /// **'activo'**
  String get illustrationMemoryBoxesVariable3;

  /// Valor de la tercera casilla de memoria de la ilustración
  ///
  /// In es, this message translates to:
  /// **'verdadero'**
  String get illustrationMemoryBoxesValue3;

  /// Rótulo de la sección y página de cuenta en ajustes
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get settingsAccount;

  /// Estado de cuenta no vinculada o sin sesión
  ///
  /// In es, this message translates to:
  /// **'Sin vincular'**
  String get settingsAccountNotLinked;

  /// Estado de cuenta vinculada con sesión activa
  ///
  /// In es, this message translates to:
  /// **'Vinculada'**
  String get settingsAccountLinked;

  /// Explicación del beneficio de la sincronización en la página de cuenta
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para sincronizar tus algoritmos y tu progreso entre dispositivos.'**
  String get settingsAccountSyncNotice;

  /// Nota que enfatiza que la aplicación funciona sin conexión ni cuenta
  ///
  /// In es, this message translates to:
  /// **'PseudoLearn funciona completamente sin cuenta. Tus algoritmos y progreso se guardan en este dispositivo.'**
  String get settingsAccountOfflineNote;

  /// Encabezado de la sección de opciones de acceso en cuenta
  ///
  /// In es, this message translates to:
  /// **'Opciones de acceso'**
  String get settingsAccountSectionOptions;

  /// Encabezado de la sección con los datos de la sesión activa
  ///
  /// In es, this message translates to:
  /// **'Sesión activa'**
  String get settingsAccountSectionSession;

  /// Aclaración bajo una dirección de reenvío privado de Apple
  ///
  /// In es, this message translates to:
  /// **'Correo privado de Apple'**
  String get settingsAccountPrivateRelay;

  /// Botón para iniciar sesión con Apple
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get authSignInWithApple;

  /// Botón para iniciar sesión con Google
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get authSignInWithGoogle;

  /// Botón para iniciar sesión con enlace mágico por correo
  ///
  /// In es, this message translates to:
  /// **'Continuar con correo'**
  String get authSignInWithEmail;

  /// Botón para cerrar sesión conservando los datos locales
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get authSignOut;

  /// Botón destructivo para cerrar sesión y eliminar los datos locales
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión y borrar datos de este dispositivo'**
  String get authSignOutAndDelete;

  /// Título del diálogo de confirmación para cerrar sesión y borrar datos locales
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión y borrar datos?'**
  String get authDeleteDataDialogTitle;

  /// Mensaje de advertencia del diálogo de confirmación de borrado local
  ///
  /// In es, this message translates to:
  /// **'Se eliminarán todos los documentos guardados en este dispositivo. Esta acción no se puede deshacer.'**
  String get authDeleteDataDialogMessage;

  /// Acción afirmativa del diálogo de confirmación de borrado local
  ///
  /// In es, this message translates to:
  /// **'Borrar datos y salir'**
  String get authDeleteDataConfirm;

  /// Botón destructivo para eliminar permanentemente la cuenta del usuario
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get authDeleteAccount;

  /// Título del diálogo de confirmación para eliminar la cuenta
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar cuenta?'**
  String get authDeleteAccountDialogTitle;

  /// Mensaje de advertencia del diálogo de confirmación de eliminación de cuenta
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta y todos los datos asociados se eliminarán permanentemente de los servidores. También se borrarán los documentos de este dispositivo. Esta acción no se puede deshacer.'**
  String get authDeleteAccountDialogMessage;

  /// Acción afirmativa del diálogo de confirmación de eliminación de cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get authDeleteAccountConfirm;

  /// Título del diálogo para ingresar correo electrónico de enlace mágico
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión con enlace mágico'**
  String get authMagicLinkDialogTitle;

  /// Etiqueta del campo de correo electrónico en el diálogo de enlace mágico
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authMagicLinkEmailLabel;

  /// Botón para enviar el enlace mágico al correo ingresado
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get authMagicLinkSend;

  /// Aviso informativo mostrado tras enviar un enlace mágico
  ///
  /// In es, this message translates to:
  /// **'Hemos enviado un enlace de acceso a {email}. Ábrelo en este dispositivo para iniciar sesión.'**
  String authMagicLinkSentNotice(String email);

  /// Indicador de progreso durante la autenticación
  ///
  /// In es, this message translates to:
  /// **'Iniciando sesión...'**
  String get authAuthenticating;

  /// Mensaje de error general de autenticación
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar sesión. Inténtalo de nuevo.'**
  String get authErrorGeneric;

  /// Mensaje de error cuando no hay conexión de red durante la autenticación
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet. Comprueba tu red.'**
  String get authErrorNoConnection;

  /// Mensaje informativo mientras la sincronización está en curso
  ///
  /// In es, this message translates to:
  /// **'Sincronizando biblioteca...'**
  String get syncBannerInProgress;

  /// Título del banner de conflicto de sincronización
  ///
  /// In es, this message translates to:
  /// **'Conflictos detectados'**
  String get syncBannerConflictTitle;

  /// Mensaje del banner de copias de conflicto detectadas
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Se ha creado 1 copia de conflicto.} other{Se han creado {count} copias de conflicto.}}'**
  String syncBannerConflictMessage(int count);

  /// Título del banner cuando ocurre un error de sincronización
  ///
  /// In es, this message translates to:
  /// **'Error de sincronización'**
  String get syncBannerErrorTitle;

  /// Mensaje detallado del error de sincronización
  ///
  /// In es, this message translates to:
  /// **'No se pudieron sincronizar algunos cambios.'**
  String get syncBannerErrorMessage;

  /// Texto del botón para reintentar la sincronización
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get syncRetryButton;

  /// Etiqueta accesible de documento sincronizado con la nube
  ///
  /// In es, this message translates to:
  /// **'Sincronizado'**
  String get syncStatusSynced;

  /// Etiqueta accesible de documento con cambios locales pendientes de sincronizar
  ///
  /// In es, this message translates to:
  /// **'Pendiente de subir'**
  String get syncStatusPending;

  /// Etiqueta accesible de documento que solo existe localmente
  ///
  /// In es, this message translates to:
  /// **'Solo en este dispositivo'**
  String get syncStatusLocalOnly;

  /// Etiqueta visual y accesible para documentos que son copia de conflicto
  ///
  /// In es, this message translates to:
  /// **'Copia de conflicto'**
  String get syncConflictBadge;

  /// Destino de navegación al panel de progreso
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get navProgress;

  /// Título de la pantalla del panel de progreso
  ///
  /// In es, this message translates to:
  /// **'Mi progreso'**
  String get dashboardTitle;

  /// Título del estado vacío del panel de progreso
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay nada que resumir'**
  String get dashboardEmptyTitle;

  /// Mensaje del estado vacío del panel de progreso
  ///
  /// In es, this message translates to:
  /// **'Escribe tu primer algoritmo o abre un módulo de la ruta de aprendizaje y aquí aparecerá tu avance.'**
  String get dashboardEmptyMessage;

  /// Título del estado de error del panel de progreso
  ///
  /// In es, this message translates to:
  /// **'No se pudo construir el panel'**
  String get dashboardErrorTitle;

  /// Título de la tarjeta de biblioteca del panel
  ///
  /// In es, this message translates to:
  /// **'Biblioteca'**
  String get dashboardLibraryTitle;

  /// Rótulo del total de algoritmos creados
  ///
  /// In es, this message translates to:
  /// **'Algoritmos creados'**
  String get dashboardLibraryTotal;

  /// Rótulo del recuento de algoritmos con perfil de sintaxis castellano
  ///
  /// In es, this message translates to:
  /// **'Perfil castellano'**
  String get dashboardLibraryProfileClassic;

  /// Rótulo del recuento de algoritmos con perfil de sintaxis inglés
  ///
  /// In es, this message translates to:
  /// **'Perfil inglés'**
  String get dashboardLibraryProfileEnglish;

  /// Título de la tarjeta de ruta de aprendizaje del panel
  ///
  /// In es, this message translates to:
  /// **'Ruta de aprendizaje'**
  String get dashboardRouteTitle;

  /// Subtítulo de la tarjeta de ruta de aprendizaje
  ///
  /// In es, this message translates to:
  /// **'Módulos visitados por tramo'**
  String get dashboardRouteSubtitle;

  /// Título de la tarjeta de ejercicios del panel
  ///
  /// In es, this message translates to:
  /// **'Ejercicios'**
  String get dashboardExercisesTitle;

  /// Rótulo del grupo de ejercicios por tramo
  ///
  /// In es, this message translates to:
  /// **'Por tramo'**
  String get dashboardExercisesByTrack;

  /// Rótulo del grupo de ejercicios por nivel
  ///
  /// In es, this message translates to:
  /// **'Por nivel'**
  String get dashboardExercisesByLevel;

  /// Rótulo del grupo de ejercicios por tipo
  ///
  /// In es, this message translates to:
  /// **'Por tipo'**
  String get dashboardExercisesByKind;

  /// Título de la tarjeta de siguiente paso del panel
  ///
  /// In es, this message translates to:
  /// **'Siguiente paso'**
  String get dashboardNextStepTitle;

  /// Mensaje cuando no queda ningún módulo por visitar
  ///
  /// In es, this message translates to:
  /// **'Has visitado los quince módulos de la ruta.'**
  String get dashboardNextStepDone;

  /// Acción para abrir el siguiente módulo sugerido
  ///
  /// In es, this message translates to:
  /// **'Abrir módulo'**
  String get dashboardNextStepOpen;

  /// Título de la tarjeta de sincronización del panel
  ///
  /// In es, this message translates to:
  /// **'Sincronización'**
  String get dashboardSyncTitle;

  /// Rótulo de la fecha de la última sincronización
  ///
  /// In es, this message translates to:
  /// **'Última sincronización'**
  String get dashboardSyncLastAt;

  /// Valor mostrado cuando nunca hubo sincronización
  ///
  /// In es, this message translates to:
  /// **'Todavía sin sincronizar'**
  String get dashboardSyncNever;

  /// Rótulo del número de cambios pendientes de subir
  ///
  /// In es, this message translates to:
  /// **'Cambios en cola'**
  String get dashboardSyncPending;

  /// Rótulo de la antigüedad del cambio pendiente más viejo
  ///
  /// In es, this message translates to:
  /// **'Antigüedad del más antiguo'**
  String get dashboardSyncOldest;

  /// Rótulo del número de copias de conflicto sin revisar
  ///
  /// In es, this message translates to:
  /// **'Conflictos abiertos'**
  String get dashboardSyncConflicts;

  /// Antigüedad en días de un cambio pendiente
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Hoy} =1{1 día} other{{count} días}}'**
  String dashboardSyncDaysAgo(int count);

  /// Título de la tarjeta de conceptos ejercitados
  ///
  /// In es, this message translates to:
  /// **'Conceptos ejercitados'**
  String get dashboardConceptsTitle;

  /// Subtítulo de la tarjeta de conceptos ejercitados
  ///
  /// In es, this message translates to:
  /// **'Construcciones que ya has escrito en tus propios algoritmos'**
  String get dashboardConceptsSubtitle;

  /// Número de algoritmos en los que aparece una construcción
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin usar} =1{En 1 algoritmo} other{En {count} algoritmos}}'**
  String dashboardConceptDocuments(int count);

  /// Nombre de la construcción condicional
  ///
  /// In es, this message translates to:
  /// **'Condicional'**
  String get dashboardConceptConditional;

  /// Nombre de la construcción de selección múltiple
  ///
  /// In es, this message translates to:
  /// **'Selección múltiple'**
  String get dashboardConceptMultipleSelection;

  /// Nombre del bucle condicional previo
  ///
  /// In es, this message translates to:
  /// **'Bucle condicional'**
  String get dashboardConceptConditionalLoop;

  /// Nombre del bucle con condición posterior
  ///
  /// In es, this message translates to:
  /// **'Bucle con condición al final'**
  String get dashboardConceptPostConditionalLoop;

  /// Nombre del bucle contado
  ///
  /// In es, this message translates to:
  /// **'Bucle contado'**
  String get dashboardConceptCountedLoop;

  /// Nombre de la declaración de arreglo
  ///
  /// In es, this message translates to:
  /// **'Arreglo'**
  String get dashboardConceptArray;

  /// Nombre de la declaración de subprograma
  ///
  /// In es, this message translates to:
  /// **'Subprograma'**
  String get dashboardConceptSubprogram;

  /// Nombre de la declaración de clase
  ///
  /// In es, this message translates to:
  /// **'Clase'**
  String get dashboardConceptClass;

  /// Título de la tarjeta de cobertura de la especificación
  ///
  /// In es, this message translates to:
  /// **'Cobertura de la especificación'**
  String get dashboardSpecificationTitle;

  /// Subtítulo de la tarjeta de cobertura de la especificación
  ///
  /// In es, this message translates to:
  /// **'Secciones normativas que tus algoritmos ya ejercitan'**
  String get dashboardSpecificationSubtitle;

  /// Estado de una sección de la especificación ya ejercitada
  ///
  /// In es, this message translates to:
  /// **'Ejercitada'**
  String get dashboardSpecificationExercised;

  /// Estado de una sección de la especificación todavía sin ejercitar
  ///
  /// In es, this message translates to:
  /// **'Sin ejercitar'**
  String get dashboardSpecificationPending;

  /// Título de la tarjeta de línea de actividad
  ///
  /// In es, this message translates to:
  /// **'Línea de actividad'**
  String get dashboardActivityTitle;

  /// Subtítulo de la tarjeta de línea de actividad
  ///
  /// In es, this message translates to:
  /// **'Módulos y ejercicios por semana'**
  String get dashboardActivitySubtitle;

  /// Título de la tarjeta de algoritmos creados por semana
  ///
  /// In es, this message translates to:
  /// **'Algoritmos creados en el tiempo'**
  String get dashboardCreationsTitle;

  /// Subtítulo de la tarjeta de algoritmos creados por semana
  ///
  /// In es, this message translates to:
  /// **'Algoritmos nuevos por semana'**
  String get dashboardCreationsSubtitle;

  /// Rótulo de una semana de la línea de actividad
  ///
  /// In es, this message translates to:
  /// **'Semana del {day}/{month}'**
  String dashboardWeekOf(int day, int month);

  /// Recuento de cobertura mostrado como parte del total
  ///
  /// In es, this message translates to:
  /// **'{done} de {total}'**
  String dashboardCoverageRatio(int done, int total);

  /// Etiqueta accesible de la tecla de sangría de la barra del editor
  ///
  /// In es, this message translates to:
  /// **'Insertar sangría'**
  String get editorKeyIndent;

  /// Etiqueta accesible de la operación que retira un nivel de sangría
  ///
  /// In es, this message translates to:
  /// **'Quitar sangría'**
  String get editorKeyDedent;

  /// Etiqueta accesible de la tecla de asignación de la barra del editor
  ///
  /// In es, this message translates to:
  /// **'Insertar asignación'**
  String get editorKeyAssignment;

  /// Etiqueta accesible de la tecla de comillas de la barra del editor
  ///
  /// In es, this message translates to:
  /// **'Insertar comillas'**
  String get editorKeyQuote;

  /// Etiqueta accesible de la tecla de paréntesis de apertura
  ///
  /// In es, this message translates to:
  /// **'Insertar paréntesis de apertura'**
  String get editorKeyOpenParenthesis;

  /// Etiqueta accesible de la tecla de paréntesis de cierre
  ///
  /// In es, this message translates to:
  /// **'Insertar paréntesis de cierre'**
  String get editorKeyCloseParenthesis;

  /// Etiqueta accesible de la tecla de comparación mayor o igual
  ///
  /// In es, this message translates to:
  /// **'Insertar mayor o igual'**
  String get editorKeyGreaterOrEqual;

  /// Etiqueta accesible de la tecla de comparación menor o igual
  ///
  /// In es, this message translates to:
  /// **'Insertar menor o igual'**
  String get editorKeyLessOrEqual;

  /// Etiqueta accesible de la tecla que despliega la fila de plantillas
  ///
  /// In es, this message translates to:
  /// **'Mostrar plantillas de estructura'**
  String get editorKeyTemplatesShow;

  /// Etiqueta accesible de la tecla que repliega la fila de plantillas
  ///
  /// In es, this message translates to:
  /// **'Ocultar plantillas de estructura'**
  String get editorKeyTemplatesHide;

  /// Etiqueta accesible de la acción que baja el teclado en pantalla desde el editor
  ///
  /// In es, this message translates to:
  /// **'Ocultar teclado'**
  String get editorActionHideKeyboard;

  /// Etiqueta accesible de la acción que despliega un panel plegable
  ///
  /// In es, this message translates to:
  /// **'Expandir'**
  String get actionExpand;

  /// Etiqueta accesible de la acción que repliega un panel desplegado
  ///
  /// In es, this message translates to:
  /// **'Contraer'**
  String get actionCollapse;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
