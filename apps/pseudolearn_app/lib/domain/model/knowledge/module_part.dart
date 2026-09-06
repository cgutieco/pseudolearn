enum ModulePart {
  question('pregunta'),
  machineModel('modelo-maquina'),
  development('desarrollo'),
  prediction('prediccion'),
  commonErrors('errores-frecuentes'),
  specificationAnchors('especificacion'),
  exercises('ejercicios');

  final String slug;

  const ModulePart(this.slug);

  static ModulePart? fromSlug(String slug) {
    for (final part in values) {
      if (part.slug == slug) return part;
    }
    return null;
  }
}
