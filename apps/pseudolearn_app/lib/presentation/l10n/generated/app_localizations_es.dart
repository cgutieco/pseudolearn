// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PseudoLearn';

  @override
  String get navEditor => 'Editor';

  @override
  String get navFlowchart => 'Ordinograma';

  @override
  String get navTrace => 'Prueba de escritorio';

  @override
  String get navKnowledge => 'Base de conocimiento';

  @override
  String get navLibrary => 'Mis algoritmos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionRun => 'Ejecutar';

  @override
  String get actionStep => 'Paso a paso';

  @override
  String get diagramZoomIn => 'Acercar';

  @override
  String get diagramZoomOut => 'Alejar';

  @override
  String get diagramFitToView => 'Encuadrar el diagrama';

  @override
  String get actionStop => 'Detener';

  @override
  String get actionStepOverBlock => 'Saltar bloque';

  @override
  String get actionStepOutOfBlock => 'Salir del bloque';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionStepInto => 'Paso';

  @override
  String get actionExport => 'Exportar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionRename => 'Renombrar';

  @override
  String get actionCreate => 'Crear';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get profileSpanish => 'Español clásico';

  @override
  String get profileEnglish => 'Inglés';

  @override
  String diagnosticsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problemas',
      one: '1 problema',
      zero: 'Sin problemas',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'Mis algoritmos';

  @override
  String get librarySearchPlaceholder => 'Buscar algoritmos...';

  @override
  String get libraryNewDocument => 'Nuevo algoritmo';

  @override
  String get libraryEmptyTitle => 'Sin algoritmos aún';

  @override
  String get libraryEmptyDescription =>
      'Crea tu primer algoritmo para empezar a programar.';

  @override
  String get libraryEmptySearchTitle => 'Sin resultados';

  @override
  String libraryEmptySearchDescription(String query) {
    return 'No se encontraron algoritmos para \"$query\".';
  }

  @override
  String get dialogNewDocTitle => 'Nuevo algoritmo';

  @override
  String get dialogNewDocNameLabel => 'Nombre del algoritmo';

  @override
  String get dialogNewDocProfileLabel => 'Perfil de sintaxis';

  @override
  String get dialogRenameDocTitle => 'Renombrar algoritmo';

  @override
  String get dialogDeleteDocTitle => 'Eliminar algoritmo';

  @override
  String dialogDeleteDocMessage(String title) {
    return '¿Estás seguro de que deseas eliminar \"$title\"? Esta acción no se puede deshacer.';
  }

  @override
  String get tabEditor => 'Editor';

  @override
  String get tabDiagrams => 'Diagramas';

  @override
  String get tabTrace => 'Prueba de escritorio';

  @override
  String get tabExport => 'Exportación';

  @override
  String get exportComingSoon =>
      'Disponible cuando el motor de exportación esté listo';

  @override
  String get outputPanelTitle => 'Salida del programa';

  @override
  String outputLinesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count líneas',
      one: '1 línea',
      zero: '0 líneas',
    );
    return '$_temp0';
  }

  @override
  String get outputPreviousExecution => 'de la ejecución anterior';

  @override
  String get outputEmpty => 'La salida del programa aparecerá aquí.';

  @override
  String stepCounter(int current, int max) {
    return 'Paso $current de $max';
  }

  @override
  String get executionStatusIdle => 'Sin ejecución';

  @override
  String executionStatusPaused(int line) {
    return 'Pausado en la línea $line';
  }

  @override
  String get executionStatusRunning => 'Ejecutando';

  @override
  String get executionStatusAwaitingInput => 'Esperando un dato';

  @override
  String get executionStatusFinished => 'Ejecución terminada';

  @override
  String get traceRowOpen => 'En curso';

  @override
  String statementCounter(int current) {
    return 'Sentencia $current';
  }

  @override
  String get trackingStripEmpty => 'Sin cambios en este paso';

  @override
  String get trackingStripLabel => 'Cambió';

  @override
  String get companionToggle => 'Acompañar';

  @override
  String get tabEquivalentCode => 'Código equivalente';

  @override
  String get bannerStepLimitTitle => 'Tope de pasos alcanzado';

  @override
  String get bannerStepLimitBody =>
      'El programa alcanzó el límite de pasos sin terminar. Revisa posibles bucles infinitos.';

  @override
  String get bannerSuccessTitle => 'Ejecución finalizada con éxito';

  @override
  String get bannerErrorTitle => 'Ejecución detenida';

  @override
  String get bannerDismiss => 'Descartar aviso';

  @override
  String get inputDialogTitle => 'Entrada de datos';

  @override
  String get inputDialogPrompt => 'Ingresa un valor para continuar:';

  @override
  String get inputDialogSubmit => 'Ingresar';

  @override
  String get diagnosticsEmpty => 'Sin problemas detectados';

  @override
  String get flowchartEmpty =>
      'El ordinograma estará disponible cuando el código no tenga errores.';

  @override
  String get structogramEmpty =>
      'El estructograma estará disponible cuando el código no tenga errores.';

  @override
  String get diagramNotationFlowchart => 'Ordinograma';

  @override
  String get diagramNotationClassDiagram => 'Diagrama de clases';

  @override
  String get classDiagramEmpty =>
      'El diagrama de clases estará disponible cuando el código no tenga errores.';

  @override
  String get classDiagramNoClasses =>
      'Este documento no declara ninguna clase.';

  @override
  String get diagramNotationStructogram => 'Estructograma';

  @override
  String get traceEmpty =>
      'Inicia la ejecución para ver la prueba de escritorio.';

  @override
  String get traceStepHeader => 'Paso';

  @override
  String get traceLineHeader => 'Línea';

  @override
  String get traceScopeHeader => 'Ámbito';

  @override
  String get knowledgeTitle => 'Base de conocimiento';

  @override
  String get knowledgeSearchPlaceholder =>
      'Buscar en la base de conocimiento...';

  @override
  String get knowledgeSectionRoute => 'Ruta';

  @override
  String get knowledgeSectionSpecification => 'Especificación';

  @override
  String get knowledgeSectionExercises => 'Ejercicios';

  @override
  String get knowledgeRouteTrackFoundations => 'Tramo A · Fundamentos';

  @override
  String get knowledgeRouteTrackImperative =>
      'Tramo B · Imperativo y estructurado';

  @override
  String get knowledgeRouteTrackObjectOriented =>
      'Tramo C · Orientación a objetos';

  @override
  String get knowledgeModuleVisited => 'Visitado';

  @override
  String get knowledgeTypeModule => 'Módulo';

  @override
  String get knowledgeTypeSpecification => 'Especificación';

  @override
  String get knowledgeTypePrediction => 'Predicción';

  @override
  String get knowledgeTypeIllustration => 'Ilustración';

  @override
  String get knowledgeTypeExample => 'Ejemplo';

  @override
  String get knowledgeTypeExercise => 'Ejercicio';

  @override
  String get knowledgeTypeReference => 'Referencia';

  @override
  String get knowledgeEmptyTitle => 'Sin contenido';

  @override
  String get knowledgeEmptyDescription =>
      'No hay contenido disponible en la base de conocimiento.';

  @override
  String get knowledgeEmptySearchTitle => 'Sin resultados';

  @override
  String knowledgeEmptySearchDescription(String query) {
    return 'No se encontraron elementos para \"$query\".';
  }

  @override
  String get knowledgeErrorTitle => 'Error de contenido';

  @override
  String get knowledgeErrorDescription =>
      'No se pudo cargar la base de conocimiento.';

  @override
  String get knowledgeActionRetry => 'Reintentar';

  @override
  String get knowledgeDetailOpenInNewDocument => 'Abrir en un documento nuevo';

  @override
  String get knowledgeDetailCopied => 'Copiado';

  @override
  String get knowledgeDetailNotFoundTitle => 'Elemento no encontrado';

  @override
  String get knowledgeDetailNotFoundDescription =>
      'El elemento solicitado no existe en la base de conocimiento.';

  @override
  String get knowledgeDetailBack => 'Volver a la base de conocimiento';

  @override
  String get knowledgeDetailSections => 'Secciones';

  @override
  String get knowledgeModulePartQuestion => 'Pregunta';

  @override
  String get knowledgeModulePartMachineModel =>
      'Qué cambia en tu modelo de la máquina';

  @override
  String get knowledgeModulePartDevelopment => 'Desarrollo';

  @override
  String get knowledgeModulePartPrediction => 'Predice y ejecuta';

  @override
  String get knowledgeModulePartCommonErrors => 'Errores frecuentes';

  @override
  String get knowledgeModulePartSpecification => 'En la especificación';

  @override
  String get knowledgeModulePartExercises => 'Ejercicios';

  @override
  String get knowledgePredictionCheck => 'Ejecutar';

  @override
  String get knowledgePredictionRetry => 'Intentar de nuevo';

  @override
  String get knowledgePredictionMatch => 'Coincide';

  @override
  String knowledgePredictionMismatch(String predicted, String actual) {
    return 'Esperabas $predicted, la máquina tiene $actual';
  }

  @override
  String get knowledgePredictionEmptyHint => 'Escribe tu predicción';

  @override
  String knowledgePredictionNotReached(int step) {
    return 'El programa no llega al paso $step';
  }

  @override
  String knowledgeSpecReturnToModule(String moduleTitle) {
    return 'Volver al módulo $moduleTitle';
  }

  @override
  String get exerciseLevel1 => 'Nivel 1 · Reproducir';

  @override
  String get exerciseLevel2 => 'Nivel 2 · Componer';

  @override
  String get exerciseLevel3 => 'Nivel 3 · Diseñar';

  @override
  String get exerciseLevelShort1 => 'Nivel 1';

  @override
  String get exerciseLevelShort2 => 'Nivel 2';

  @override
  String get exerciseLevelShort3 => 'Nivel 3';

  @override
  String get exerciseKindPredict => 'Predecir';

  @override
  String get exerciseKindComplete => 'Completar';

  @override
  String get exerciseKindModify => 'Modificar';

  @override
  String get exerciseKindCreate => 'Crear';

  @override
  String get exerciseCompletedBadge => 'Superado';

  @override
  String get exerciseFilterLevel => 'Nivel';

  @override
  String get exerciseFilterModule => 'Módulo';

  @override
  String get exerciseFilterConstruct => 'Construcción';

  @override
  String get exerciseFilterAllLevels => 'Todos los niveles';

  @override
  String get exerciseFilterAllConstructs => 'Todas las construcciones';

  @override
  String get exerciseConstructConditional => 'Condicional';

  @override
  String get exerciseConstructMultipleSelection => 'Selección múltiple';

  @override
  String get exerciseConstructConditionalLoop => 'Bucle condicional';

  @override
  String get exerciseConstructPostConditionalLoop => 'Bucle posterior';

  @override
  String get exerciseConstructCountedLoop => 'Bucle contado';

  @override
  String get exerciseConstructArrayDeclaration => 'Arreglos';

  @override
  String get exerciseConstructSubprogram => 'Subprogramas';

  @override
  String get exerciseConstructClassDeclaration => 'Clases';

  @override
  String get exerciseClearFilters => 'Limpiar filtros';

  @override
  String get exerciseBankEmptyTitle => 'Sin ejercicios';

  @override
  String get exerciseBankEmptyDescription =>
      'No hay ejercicios disponibles en la base de conocimiento.';

  @override
  String get exerciseBankEmptyFilterTitle => 'Sin resultados';

  @override
  String get exerciseBankEmptyFilterDescription =>
      'Ningún ejercicio coincide con los filtros o la búsqueda seleccionada.';

  @override
  String exerciseStripTitle(String title) {
    return 'Ejercicio: $title';
  }

  @override
  String get exerciseStripCollapse => 'Contraer franja de ejercicio';

  @override
  String get exerciseStripExpand => 'Expandir franja de ejercicio';

  @override
  String get exerciseActionCheck => 'Comprobar';

  @override
  String get exerciseChecking => 'Comprobando...';

  @override
  String exercisePassedCount(int passed, int total) {
    return 'Cumple $passed de $total casos';
  }

  @override
  String get exerciseAllCasesPassed => '¡Cumple todos los casos de prueba!';

  @override
  String get exerciseHiddenFailureTitle => 'Primer caso oculto fallido:';

  @override
  String exerciseHiddenInputs(String inputs) {
    return 'Entrada: $inputs';
  }

  @override
  String exerciseHiddenExpected(String expected) {
    return 'Salida esperada: $expected';
  }

  @override
  String exerciseHiddenActual(String actual) {
    return 'Salida obtenida: $actual';
  }

  @override
  String get exerciseOutcomeParseError =>
      'El programa contiene errores de sintaxis y no puede comprobarse.';

  @override
  String get exerciseOutcomeHalted =>
      'La ejecución se detuvo de forma anómala.';

  @override
  String get exerciseOutcomeStepLimit =>
      'Se agotó el límite de pasos (posible bucle infinito).';

  @override
  String get exerciseOutcomeInputExhausted =>
      'El programa solicitó más entradas de las previstas.';

  @override
  String get exerciseNotFoundTitle => 'Ejercicio no disponible';

  @override
  String exerciseNotFoundInCatalog(String id) {
    return 'El ejercicio vinculado ($id) no existe en el catálogo. Puedes editar y ejecutar este documento con normalidad.';
  }

  @override
  String get exerciseVisibleCasesTitle => 'Casos de prueba visibles:';

  @override
  String exerciseCaseInputsLabel(String inputs) {
    return 'Entrada: $inputs';
  }

  @override
  String exerciseCaseOutputsLabel(String outputs) {
    return 'Salida esperada: $outputs';
  }

  @override
  String exerciseUnmetAssertion(String requirement) {
    return 'Falta la restricción: $requirement';
  }

  @override
  String onboardingStepOf(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a PseudoLearn';

  @override
  String get onboardingWelcomeSubtitle =>
      'Escribe pseudocódigo y mira cómo se ejecuta: diagramas, prueba de escritorio y salida, todo a la vez.';

  @override
  String get onboardingWelcomeHighlightEngine =>
      'Un motor que ejecuta de verdad, instrucción a instrucción';

  @override
  String get onboardingWelcomeHighlightDiagrams =>
      'Ordinograma, estructograma y diagrama de clases del mismo programa';

  @override
  String get onboardingWelcomeHighlightRoute =>
      'Una ruta de aprendizaje con ejercicios que se comprueban solos';

  @override
  String get onboardingLabTitle => 'El laboratorio en vivo';

  @override
  String get onboardingLabSubtitle =>
      'Pulsa «Paso a paso» y observa cómo reaccionan a la vez el código, los diagramas, la prueba de escritorio y la salida.';

  @override
  String get onboardingLabBriefTitle => 'La casuística';

  @override
  String get onboardingLabBriefStatement =>
      'Un termómetro empieza en 30 grados y se enfría de tres en tres hasta llegar a los 24 grados de confort. Cuenta cuántas veces se enfrió y anuncia el resultado.';

  @override
  String get onboardingLabReadOnly =>
      'Vista de solo lectura: aquí se observa, no se edita.';

  @override
  String get onboardingLabSurfaceDiagrams => 'Diagramas';

  @override
  String get onboardingLabSurfaceTrace => 'Prueba de escritorio';

  @override
  String get onboardingLabSurfaceOutput => 'Salida';

  @override
  String get onboardingLabActionRestart => 'Reiniciar';

  @override
  String get onboardingLabStatusReady =>
      'Listo para ejecutar la primera instrucción.';

  @override
  String onboardingLabStatusStepping(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instrucciones ejecutadas',
      one: '1 instrucción ejecutada',
    );
    return '$_temp0';
  }

  @override
  String get onboardingLabStatusFinished =>
      'Programa terminado. Reinicia para volver a verlo.';

  @override
  String get onboardingLabUnavailable =>
      'La demostración no está disponible ahora mismo. Puedes continuar sin ella.';

  @override
  String get onboardingKnowledgeTitle => 'Tu base de conocimiento';

  @override
  String get onboardingKnowledgeSubtitle =>
      'No estás solo frente a la hoja en blanco: hay una ruta, una especificación y un banco de ejercicios esperándote.';

  @override
  String get onboardingKnowledgeRouteTitle => 'Ruta personalizada';

  @override
  String get onboardingKnowledgeRouteDescription =>
      'Tres tramos encadenados que llevan desde los fundamentos hasta la programación orientada a objetos con pseudocódigo.';

  @override
  String get onboardingKnowledgeTrackFoundations => 'Fundamentos';

  @override
  String get onboardingKnowledgeTrackImperative => 'Programación imperativa';

  @override
  String get onboardingKnowledgeTrackObjectOriented =>
      'Objetos con pseudocódigo';

  @override
  String onboardingKnowledgeModuleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count módulos',
      one: '1 módulo',
    );
    return '$_temp0';
  }

  @override
  String get onboardingKnowledgeSpecificationTitle =>
      'Especificación de sintaxis';

  @override
  String get onboardingKnowledgeSpecificationDescription =>
      'Cada construcción del lenguaje, con su forma exacta y sus ejemplos ejecutables.';

  @override
  String onboardingKnowledgeSpecificationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secciones',
      one: '1 sección',
    );
    return '$_temp0';
  }

  @override
  String get onboardingKnowledgeExercisesTitle => 'Banco de ejercicios';

  @override
  String get onboardingKnowledgeExercisesDescription =>
      'Enunciados con casos de prueba que la aplicación comprueba por ti, ordenados por dificultad.';

  @override
  String onboardingKnowledgeExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios',
      one: '1 ejercicio',
    );
    return '$_temp0';
  }

  @override
  String onboardingKnowledgeLevelCount(int level, int count) {
    return 'Nivel $level: $count';
  }

  @override
  String get onboardingKnowledgeUnavailable =>
      'El catálogo no se pudo leer ahora mismo. Estará disponible dentro de la aplicación.';

  @override
  String get onboardingCompletionTitle => '¡Todo listo para empezar!';

  @override
  String get onboardingCompletionSubtitle =>
      'Crea tu primer algoritmo desde cero, o entra por la ruta de aprendizaje si prefieres que te guíen.';

  @override
  String get onboardingActionCreateFirst => 'Crear mi primer documento';

  @override
  String get onboardingActionExploreRoute => 'Entrar en la ruta de aprendizaje';

  @override
  String get onboardingActionNext => 'Siguiente';

  @override
  String get onboardingActionBack => 'Atrás';

  @override
  String get onboardingActionSkip => 'Saltar';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionInformation => 'Información';

  @override
  String get settingsLanguage => 'Idioma de la interfaz';

  @override
  String get settingsLanguageNotice =>
      'No cambia el vocabulario de tus documentos';

  @override
  String get settingsTheme => 'Tema visual';

  @override
  String get settingsThemeSystem => 'Tema del sistema';

  @override
  String get settingsThemeLight => 'Tema claro';

  @override
  String get settingsThemeDark => 'Tema oscuro';

  @override
  String get settingsRestartOnboarding => 'Ver la introducción de nuevo';

  @override
  String get settingsContact => 'Contacto y soporte';

  @override
  String settingsVersion(String version) {
    return 'v$version';
  }

  @override
  String get settingsBack => 'Volver a Ajustes';

  @override
  String get settingsAbout => 'Sobre este ajuste';

  @override
  String get settingsLanguageOptions => 'Idiomas disponibles';

  @override
  String get settingsThemeOptions => 'Temas disponibles';

  @override
  String get settingsThemeNotice =>
      '«Tema del sistema» sigue la apariencia clara u oscura de tu equipo';

  @override
  String get settingsDiagramAssist => 'Zoom asistido en diagramas';

  @override
  String get settingsDiagramAssistOptions =>
      'Comportamiento al ejecutar paso a paso';

  @override
  String get settingsDiagramAssistOn => 'Seguir el paso activo';

  @override
  String get settingsDiagramAssistOff => 'No mover el diagrama';

  @override
  String get settingsDiagramAssistNotice =>
      'Con el seguimiento activo, el diagrama se acerca al bloque en ejecución y se desplaza hasta el siguiente sin saltos';

  @override
  String get settingsContactTitle => 'Contacto y soporte';

  @override
  String get settingsContactEmpty =>
      'No hay información de contacto disponible.';

  @override
  String get settingsContactTipsTitle => 'Consejos para reportar incidencias';

  @override
  String get settingsContactTipsBody =>
      'Al escribirnos sobre un problema técnico, describe los pasos para reproducirlo e incluye el fragmento de pseudocódigo afectado para ayudarte con mayor rapidez.';

  @override
  String get targetLanguagePython => 'Python';

  @override
  String get targetLanguageRust => 'Rust';

  @override
  String get exportAnalysisErrorTitle => 'Programa con errores';

  @override
  String get exportAnalysisErrorDescription =>
      'Corrige los errores en el editor para ver el código exportado.';

  @override
  String get exportCopyTooltip => 'Copiar código';

  @override
  String get exportCopiedTooltip => '¡Copiado!';

  @override
  String get exportEmptySourceDescription =>
      'Escribe o abre un algoritmo para ver su traducción.';

  @override
  String get exportNotesTitle => 'Notas de exportación';

  @override
  String get libraryDocumentOptions => 'Opciones del documento';

  @override
  String get severityError => 'ERROR';

  @override
  String get severityWarning => 'AVISO';

  @override
  String get severityInfo => 'INFO';

  @override
  String get severityHint => 'PISTA';

  @override
  String get severitySuccess => 'ÉXITO';

  @override
  String get validationNameEmpty => 'El nombre no puede estar vacío';

  @override
  String get validationNameDuplicate =>
      'Ya existe un documento con este nombre';

  @override
  String get executionRuntimeError => 'Error en tiempo de ejecución';

  @override
  String get illustrationMemoryBoxesSemanticLabel =>
      'Ilustración: tres casillas de memoria, cada una con su nombre encima y su valor dentro.';

  @override
  String get illustrationMemoryBoxesVariable1 => 'contador';

  @override
  String get illustrationMemoryBoxesValue1 => '3';

  @override
  String get illustrationMemoryBoxesVariable2 => 'total';

  @override
  String get illustrationMemoryBoxesValue2 => '12.5';

  @override
  String get illustrationMemoryBoxesVariable3 => 'activo';

  @override
  String get illustrationMemoryBoxesValue3 => 'verdadero';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsAccountNotLinked => 'Sin vincular';

  @override
  String get settingsAccountLinked => 'Vinculada';

  @override
  String get settingsAccountSyncNotice =>
      'Inicia sesión para sincronizar tus algoritmos y tu progreso entre dispositivos.';

  @override
  String get settingsAccountOfflineNote =>
      'PseudoLearn funciona completamente sin cuenta. Tus algoritmos y progreso se guardan en este dispositivo.';

  @override
  String get settingsAccountSectionOptions => 'Opciones de acceso';

  @override
  String get settingsAccountSectionSession => 'Sesión activa';

  @override
  String get settingsAccountPrivateRelay => 'Correo privado de Apple';

  @override
  String get authSignInWithApple => 'Continuar con Apple';

  @override
  String get authSignInWithGoogle => 'Continuar con Google';

  @override
  String get authSignInWithEmail => 'Continuar con correo';

  @override
  String get authSignOut => 'Cerrar sesión';

  @override
  String get authSignOutAndDelete =>
      'Cerrar sesión y borrar datos de este dispositivo';

  @override
  String get authDeleteDataDialogTitle => '¿Cerrar sesión y borrar datos?';

  @override
  String get authDeleteDataDialogMessage =>
      'Se eliminarán todos los documentos guardados en este dispositivo. Esta acción no se puede deshacer.';

  @override
  String get authDeleteDataConfirm => 'Borrar datos y salir';

  @override
  String get authDeleteAccount => 'Eliminar cuenta';

  @override
  String get authDeleteAccountDialogTitle => '¿Eliminar cuenta?';

  @override
  String get authDeleteAccountDialogMessage =>
      'Tu cuenta y todos los datos asociados se eliminarán permanentemente de los servidores. También se borrarán los documentos de este dispositivo. Esta acción no se puede deshacer.';

  @override
  String get authDeleteAccountConfirm => 'Eliminar cuenta';

  @override
  String get authMagicLinkDialogTitle => 'Iniciar sesión con enlace mágico';

  @override
  String get authMagicLinkEmailLabel => 'Correo electrónico';

  @override
  String get authMagicLinkSend => 'Enviar enlace';

  @override
  String authMagicLinkSentNotice(String email) {
    return 'Hemos enviado un enlace de acceso a $email. Ábrelo en este dispositivo para iniciar sesión.';
  }

  @override
  String get authAuthenticating => 'Iniciando sesión...';

  @override
  String get authErrorGeneric =>
      'No se pudo iniciar sesión. Inténtalo de nuevo.';

  @override
  String get authErrorNoConnection =>
      'Sin conexión a internet. Comprueba tu red.';

  @override
  String get syncBannerInProgress => 'Sincronizando biblioteca...';

  @override
  String get syncBannerConflictTitle => 'Conflictos detectados';

  @override
  String syncBannerConflictMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se han creado $count copias de conflicto.',
      one: 'Se ha creado 1 copia de conflicto.',
    );
    return '$_temp0';
  }

  @override
  String get syncBannerErrorTitle => 'Error de sincronización';

  @override
  String get syncBannerErrorMessage =>
      'No se pudieron sincronizar algunos cambios.';

  @override
  String get syncRetryButton => 'Reintentar';

  @override
  String get syncStatusSynced => 'Sincronizado';

  @override
  String get syncStatusPending => 'Pendiente de subir';

  @override
  String get syncStatusLocalOnly => 'Solo en este dispositivo';

  @override
  String get syncConflictBadge => 'Copia de conflicto';

  @override
  String get navProgress => 'Progreso';

  @override
  String get dashboardTitle => 'Mi progreso';

  @override
  String get dashboardEmptyTitle => 'Todavía no hay nada que resumir';

  @override
  String get dashboardEmptyMessage =>
      'Escribe tu primer algoritmo o abre un módulo de la ruta de aprendizaje y aquí aparecerá tu avance.';

  @override
  String get dashboardErrorTitle => 'No se pudo construir el panel';

  @override
  String get dashboardLibraryTitle => 'Biblioteca';

  @override
  String get dashboardLibraryTotal => 'Algoritmos creados';

  @override
  String get dashboardLibraryProfileClassic => 'Perfil castellano';

  @override
  String get dashboardLibraryProfileEnglish => 'Perfil inglés';

  @override
  String get dashboardRouteTitle => 'Ruta de aprendizaje';

  @override
  String get dashboardRouteSubtitle => 'Módulos visitados por tramo';

  @override
  String get dashboardExercisesTitle => 'Ejercicios';

  @override
  String get dashboardExercisesByTrack => 'Por tramo';

  @override
  String get dashboardExercisesByLevel => 'Por nivel';

  @override
  String get dashboardExercisesByKind => 'Por tipo';

  @override
  String get dashboardNextStepTitle => 'Siguiente paso';

  @override
  String get dashboardNextStepDone =>
      'Has visitado los quince módulos de la ruta.';

  @override
  String get dashboardNextStepOpen => 'Abrir módulo';

  @override
  String get dashboardSyncTitle => 'Sincronización';

  @override
  String get dashboardSyncLastAt => 'Última sincronización';

  @override
  String get dashboardSyncNever => 'Todavía sin sincronizar';

  @override
  String get dashboardSyncPending => 'Cambios en cola';

  @override
  String get dashboardSyncOldest => 'Antigüedad del más antiguo';

  @override
  String get dashboardSyncConflicts => 'Conflictos abiertos';

  @override
  String dashboardSyncDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
      zero: 'Hoy',
    );
    return '$_temp0';
  }

  @override
  String get dashboardConceptsTitle => 'Conceptos ejercitados';

  @override
  String get dashboardConceptsSubtitle =>
      'Construcciones que ya has escrito en tus propios algoritmos';

  @override
  String dashboardConceptDocuments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'En $count algoritmos',
      one: 'En 1 algoritmo',
      zero: 'Sin usar',
    );
    return '$_temp0';
  }

  @override
  String get dashboardConceptConditional => 'Condicional';

  @override
  String get dashboardConceptMultipleSelection => 'Selección múltiple';

  @override
  String get dashboardConceptConditionalLoop => 'Bucle condicional';

  @override
  String get dashboardConceptPostConditionalLoop =>
      'Bucle con condición al final';

  @override
  String get dashboardConceptCountedLoop => 'Bucle contado';

  @override
  String get dashboardConceptArray => 'Arreglo';

  @override
  String get dashboardConceptSubprogram => 'Subprograma';

  @override
  String get dashboardConceptClass => 'Clase';

  @override
  String get dashboardSpecificationTitle => 'Cobertura de la especificación';

  @override
  String get dashboardSpecificationSubtitle =>
      'Secciones normativas que tus algoritmos ya ejercitan';

  @override
  String get dashboardSpecificationExercised => 'Ejercitada';

  @override
  String get dashboardSpecificationPending => 'Sin ejercitar';

  @override
  String get dashboardActivityTitle => 'Línea de actividad';

  @override
  String get dashboardActivitySubtitle => 'Módulos y ejercicios por semana';

  @override
  String get dashboardCreationsTitle => 'Algoritmos creados en el tiempo';

  @override
  String get dashboardCreationsSubtitle => 'Algoritmos nuevos por semana';

  @override
  String dashboardWeekOf(int day, int month) {
    return 'Semana del $day/$month';
  }

  @override
  String dashboardCoverageRatio(int done, int total) {
    return '$done de $total';
  }

  @override
  String get editorKeyIndent => 'Insertar sangría';

  @override
  String get editorKeyDedent => 'Quitar sangría';

  @override
  String get editorKeyAssignment => 'Insertar asignación';

  @override
  String get editorKeyQuote => 'Insertar comillas';

  @override
  String get editorKeyOpenParenthesis => 'Insertar paréntesis de apertura';

  @override
  String get editorKeyCloseParenthesis => 'Insertar paréntesis de cierre';

  @override
  String get editorKeyGreaterOrEqual => 'Insertar mayor o igual';

  @override
  String get editorKeyLessOrEqual => 'Insertar menor o igual';

  @override
  String get editorKeyTemplatesShow => 'Mostrar plantillas de estructura';

  @override
  String get editorKeyTemplatesHide => 'Ocultar plantillas de estructura';

  @override
  String get editorActionHideKeyboard => 'Ocultar teclado';

  @override
  String get actionExpand => 'Expandir';

  @override
  String get actionCollapse => 'Contraer';
}
