import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_model.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/analysis/analysis_cache.dart';
import 'package:pseudolearn_app/engine/classdiagram/class_model_extractor.dart';
import 'package:pseudolearn_app/engine/classdiagram/member_signature_printer.dart';

const String _vehicles = '''
Clase Vehiculo
    Publico Definir marca Como Cadena
    Privado Definir velocidad Como Entero

    Metodo Constructor(m Como Cadena)
        Este.marca <- m
    FinMetodo

    Publico Metodo Acelerar(delta Como Entero)
        Este.velocidad <- Este.velocidad + delta
    FinMetodo

    Privado Metodo Interno() Como Entero
        Retornar Este.velocidad
    FinMetodo
FinClase

Clase Motocicleta Hereda De Vehiculo
    Publico Definir cilindrada Como Entero

    Metodo Describir()
        Escribir Este.cilindrada
    FinMetodo
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

const String _garage = '''
Clase Motor
    Publico Definir potencia Como Entero
FinClase

Clase Coche
    Publico Definir motor Como Motor
    Publico Definir nombre Como Cadena
FinClase

Clase Flota
    Publico Dimension coches[10] Como Coche
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

const String _threeLevels = '''
Clase Base
    Publico Definir uno Como Entero
FinClase

Clase Media Hereda De Base
    Publico Definir dos Como Entero
FinClase

Clase Hoja Hereda De Media
    Publico Definir tres Como Entero
FinClase

Clase Hermana Hereda De Base
    Publico Definir cuatro Como Entero
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

const String _cyclic = '''
Clase Uno Hereda De Dos
    Publico Definir a Como Entero
FinClase
Clase Dos Hereda De Uno
    Publico Definir b Como Entero
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

const String _orphanSuperclass = '''
Clase Sola Hereda De NoDeclarada
    Publico Definir a Como Entero
FinClase

Proceso Principal
    Definir n Como Entero
FinProceso
''';

ClassModel _modelOf(String source, {
  SyntaxProfileId profileId = SyntaxProfileId.classicSpanish,
}) {
  final analysis = AnalysisCache().of(source, profileId);
  return ClassModelExtractor(MemberSignaturePrinter(analysis.profile))
      .of(analysis.sourceUnit);
}

ClassBox _classNamed(ClassModel model, String name) {
  for (final box in model.classes) {
    if (box.name == name) return box;
  }
  throw StateError('no class named $name');
}

void main() {
  group('ClassModelExtractor', () {
    test('reads attributes and methods of both visibilities', () {
      final vehicle = _classNamed(_modelOf(_vehicles), 'Vehiculo');

      expect(vehicle.attributes.length, 2);
      expect(vehicle.attributes[0].text, 'marca: Cadena');
      expect(vehicle.attributes[0].visibility, ClassMemberVisibility.public);
      expect(vehicle.attributes[1].text, 'velocidad: Entero');
      expect(vehicle.attributes[1].visibility, ClassMemberVisibility.private);
      expect(vehicle.methods.length, 3);
      expect(vehicle.methods[0].text, 'Constructor(m: Cadena)');
      expect(vehicle.methods[1].text, 'Acelerar(delta: Entero)');
      expect(vehicle.methods[2].text, 'Interno(): Entero');
      expect(vehicle.methods[2].visibility, ClassMemberVisibility.private);
    });

    test('keeps the node identifier of every class and member', () {
      final vehicle = _classNamed(_modelOf(_vehicles), 'Vehiculo');

      expect(vehicle.nodeId.value, greaterThan(0));
      expect(vehicle.sourceLine, 1);
      for (final row in vehicle.methods) {
        expect(row.nodeId.value, greaterThan(0));
        expect(row.sourceLine, greaterThan(0));
      }
    });

    test('emits a generalization for a declared superclass', () {
      final model = _modelOf(_vehicles);
      final relations = model.relations;

      expect(relations.length, 1);
      expect(relations.first.kind, ClassRelationKind.generalization);
      expect(relations.first.fromClassName, 'Motocicleta');
      expect(relations.first.toClassName, 'Vehiculo');
    });

    test('emits no relation for a superclass that is not declared', () {
      final model = _modelOf(_orphanSuperclass);

      expect(model.relations, isEmpty);
      expect(model.classes.single.superclassName, 'NoDeclarada');
    });

    test('emits an association for an attribute of a declared class type', () {
      final model = _modelOf(_garage);
      final associations = [
        for (final relation in model.relations)
          if (relation.kind == ClassRelationKind.association) relation,
      ];

      expect(associations.length, 2);
      expect(associations[0].fromClassName, 'Coche');
      expect(associations[0].toClassName, 'Motor');
      expect(associations[0].label, 'motor 1');
      expect(associations[1].fromClassName, 'Flota');
      expect(associations[1].toClassName, 'Coche');
      expect(associations[1].label, 'coches *');
    });

    test('emits no association for an attribute of a primitive type', () {
      final model = _modelOf(_garage);

      for (final relation in model.relations) {
        expect(relation.toClassName, isNot('Cadena'));
      }
    });

    test('reads a hierarchy of three levels with two siblings', () {
      final model = _modelOf(_threeLevels);

      expect(model.classes.length, 4);
      expect(_classNamed(model, 'Hoja').superclassName, 'Media');
      expect(_classNamed(model, 'Hermana').superclassName, 'Base');
      expect(model.relations.length, 3);
    });

    test('reads cyclic inheritance without looping', () {
      final model = _modelOf(_cyclic);

      expect(model.classes.length, 2);
      expect(model.relations.length, 2);
    });

    test('a program without classes produces an empty model', () {
      final model = _modelOf('Proceso P\n    Definir a Como Entero\nFinProceso\n');

      expect(model.isEmpty, isTrue);
      expect(model.relations, isEmpty);
    });

    test('an unparseable program produces an empty model', () {
      final model = _modelOf('Clase');

      expect(model.isEmpty, isTrue);
    });

    test('an empty class keeps both compartments empty', () {
      final model = _modelOf('Clase V\nFinClase\nProceso P\n    Definir a Como Entero\nFinProceso\n');

      expect(model.classes.single.attributes, isEmpty);
      expect(model.classes.single.methods, isEmpty);
    });

    test('a class named with a single character is read', () {
      final model = _modelOf(
        'Clase A\n    Publico Definir b Como Entero\nFinClase\n'
        'Proceso P\n    Definir a Como Entero\nFinProceso\n',
      );

      expect(model.classes.single.name, 'A');
      expect(model.classes.single.attributes.single.text, 'b: Entero');
    });

    test('types are printed with the lexemes of the english profile', () {
      const source = '''
class Vehicle
    public define brand as string;

    public method Speed() as integer
        return 0;
    endMethod
endClass

algorithm Main
    define n as integer;
endAlgorithm
''';
      final model = _modelOf(source, profileId: SyntaxProfileId.english);
      final vehicle = model.classes.single;

      expect(vehicle.attributes.single.text, 'brand: string');
      expect(vehicle.methods.single.text, 'Speed(): integer');
    });
  });
}
