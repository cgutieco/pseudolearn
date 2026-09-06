final class ClassDiagramCorpus {
  static const String robotAutonomo = '''
Clase Componente
    Publico Definir codigo Como Cadena
    Publico Definir costo Como Real

    Metodo Constructor(cod Como Cadena, c Como Real)
        Este.codigo <- cod
        Este.costo <- c
    FinMetodo

    Publico Metodo ObtenerCosto() Como Real
        Retornar Este.costo
    FinMetodo
FinClase

Clase Dispositivo Hereda De Componente
    Publico Definir fabricante Como Cadena

    Metodo Constructor(cod Como Cadena, c Como Real, fab Como Cadena)
        Este.codigo <- cod
        Este.costo <- c
        Este.fabricante <- fab
    FinMetodo
FinClase

Clase Sensor Hereda De Dispositivo
    Publico Definir tipoSensor Como Cadena
    Publico Definir resolucion Como Entero

    Metodo Constructor(cod Como Cadena, c Como Real, fab Como Cadena, t Como Cadena, res Como Entero)
        Este.codigo <- cod
        Este.costo <- c
        Este.fabricante <- fab
        Este.tipoSensor <- t
        Este.resolucion <- res
    FinMetodo
FinClase

Clase Computadora Hereda De Dispositivo
    Publico Definir frecuenciaGhz Como Real
    Publico Definir memoriaRamMb Como Entero

    Metodo Constructor(cod Como Cadena, c Como Real, fab Como Cadena, freq Como Real, ram Como Entero)
        Este.codigo <- cod
        Este.costo <- c
        Este.fabricante <- fab
        Este.frecuenciaGhz <- freq
        Este.memoriaRamMb <- ram
    FinMetodo
FinClase

Clase RobotAutonomo Hereda De Componente
    Publico Definir bateriaMah Como Entero
    Publico Definir cerebro Como Computadora
    Publico Definir procesador Como Computadora
    Publico Definir sensorOptico Como Sensor

    Metodo Constructor(cod Como Cadena, c Como Real, bat Como Entero, comp Como Computadora, sens Como Sensor)
        Este.codigo <- cod
        Este.costo <- c
        Este.bateriaMah <- bat
        Este.cerebro <- comp
        Este.procesador <- comp
        Este.sensorOptico <- sens
    FinMetodo

    Publico Metodo Operar()
        Escribir Este.codigo
    FinMetodo
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

  static const String singleEmptyClass = '''
Clase Vacia
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

  static const String singleClassWithMembers = '''
Clase Contador
    Privado Definir valor Como Entero

    Metodo Constructor(inicial Como Entero)
        Este.valor <- inicial
    FinMetodo

    Publico Metodo Incrementar()
        Este.valor <- Este.valor + 1
    FinMetodo

    Publico Metodo Obtener() Como Entero
        Retornar Este.valor
    FinMetodo
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

  static const String deepInheritance = '''
Clase NivelUno
    Publico Definir a Como Entero
FinClase

Clase NivelDos Hereda De NivelUno
    Publico Definir b Como Entero
FinClase

Clase NivelTres Hereda De NivelDos
    Publico Definir c Como Entero
FinClase

Clase NivelCuatro Hereda De NivelTres
    Publico Definir d Como Entero
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

  static const String cyclicInheritance = '''
Clase CicloA Hereda De CicloB
    Publico Definir campoA Como Entero
FinClase

Clase CicloB Hereda De CicloA
    Publico Definir campoB Como Entero
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

  static const String selfAssociation = '''
Clase NodoLista
    Publico Definir dato Como Entero
    Publico Definir siguiente Como NodoLista

    Metodo Constructor(d Como Entero, sig Como NodoLista)
        Este.dato <- d
        Este.siguiente <- sig
    FinMetodo
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

  static const String longMemberSignatures = '''
Clase ServicioConfiguracionExtensa
    Privado Definir identificadorUnicoGlobal Como Cadena

    Metodo Constructor(identificadorPrincipal Como Cadena, direccionServidorPrimario Como Cadena, puertoAccesoSeguro Como Entero, tiempoEsperaConexionMs Como Entero, limiteReintentosMaximo Como Entero, habilitarCifradoExtremo Como Logico, tokenAutenticacionInicial Como Cadena, claveSecretaSeguridad Como Cadena)
        Este.identificadorUnicoGlobal <- identificadorPrincipal
    FinMetodo

    Publico Metodo ConfigurarParametrosAvanzadosDeRed(direccionIpServidorDNS Como Cadena, mascaraSubredLocal Como Cadena, puertaEnlacePredeterminada Como Cadena) Como Logico
        Retornar Verdadero
    FinMetodo
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

  static const String singleCharIdentifiers = '''
Clase Ca
    Publico Definir k Como Entero
FinClase

Clase Da Hereda De Ca
    Publico Definir m Como Entero
    Publico Definir p1 Como Ca
FinClase

Clase Fa Hereda De Ca
    Publico Definir r Como Entero
    Publico Definir q1 Como Da
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

  static const String denseProgram = '''
Clase E1
    Publico Definir a Como Entero
FinClase

Clase E2 Hereda De E1
    Publico Definir e1 Como E1
FinClase

Clase E3 Hereda De E1
    Publico Definir e2 Como E2
FinClase

Clase E4
    Publico Definir e1 Como E1
    Publico Definir e2 Como E2
FinClase

Clase E5 Hereda De E4
    Publico Definir e3 Como E3
FinClase

Clase E6
    Publico Definir e4 Como E4
    Publico Definir e5 Como E5
FinClase

Clase E7 Hereda De E6
    Publico Definir e2 Como E2
FinClase

Clase E8
    Publico Definir e7 Como E7
    Publico Definir e6 Como E6
FinClase

Clase E9 Hereda De E8
    Publico Definir e1 Como E1
    Publico Definir e3 Como E3
FinClase

Clase E10
    Publico Definir e9 Como E9
    Publico Definir e8 Como E8
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

  static const String disjointHierarchies = '''
Clase Animal
    Publico Definir especie Como Cadena
FinClase

Clase Perro Hereda De Animal
    Publico Definir raza Como Cadena
FinClase

Clase Vehiculo
    Publico Definir marca Como Cadena
FinClase

Clase Auto Hereda De Vehiculo
    Publico Definir modelo Como Cadena
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

  static const Map<String, String> all = {
    'robotAutonomo': robotAutonomo,
    'singleEmptyClass': singleEmptyClass,
    'singleClassWithMembers': singleClassWithMembers,
    'deepInheritance': deepInheritance,
    'cyclicInheritance': cyclicInheritance,
    'selfAssociation': selfAssociation,
    'longMemberSignatures': longMemberSignatures,
    'singleCharIdentifiers': singleCharIdentifiers,
    'denseProgram': denseProgram,
    'disjointHierarchies': disjointHierarchies,
  };
}
