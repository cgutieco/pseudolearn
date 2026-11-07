(() => {
  const categorias = {
    "k-e": "Proceso FinProceso Algoritmo FinAlgoritmo Definir Dimension Leer Escribir Mostrar Si Entonces Sino FinSi Segun Hacer FinSegun De Otro Modo Mientras FinMientras Repetir Hasta Que Para Con Paso FinPara Cada Salir Diferir FinDiferir Como Constante",
    "k-p": "SubProceso FinSubProceso Funcion FinFuncion Retornar Suspendible Tareas FinTareas Lanzar Aguardar Elegir FinElegir Recibir Desde Propagar Descartar Por Referencia Valor",
    "k-o": "Clase FinClase Metodo FinMetodo Constructor Nuevo Este Super Hereda Publico Privado",
    "k-t": "Entero Real Logico Caracter Cadena Tarea Canal Vector Diccionario Opcional Resultado Inmutable Algo Nada Exito Error",
    "k-b": "Verdadero Falso",
    "k-g": "Y O NO div mod"
  };

  const claseDePalabra = new Map();
  for (const [clase, lista] of Object.entries(categorias)) {
    for (const palabra of lista.split(" ")) claseDePalabra.set(palabra, clase);
  }

  const escapar = (texto) =>
    texto.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

  const patron = /(«[^»]*»)|(\/\/.*$)|("(?:\\.|[^"\\])*"?|'(?:\\.|[^'\\])*'?)|(\d+(?:\.\d+)?)|([A-Za-zÁÉÍÓÚÜÑáéíóúüñ_][A-Za-zÁÉÍÓÚÜÑáéíóúüñ_0-9]*)|(\s+)|(.)/gm;

  const resaltarLinea = (linea) => {
    let html = "";
    for (const m of linea.matchAll(patron)) {
      const [todo, hueco, comentario, texto, numero, palabra, espacio] = m;
      if (hueco) html += `<span class="hueco">${escapar(hueco.slice(1, -1))}</span>`;
      else if (comentario) html += `<span class="k-c">${escapar(comentario)}</span>`;
      else if (texto) html += `<span class="k-s">${escapar(texto)}</span>`;
      else if (numero) html += `<span class="k-n">${numero}</span>`;
      else if (palabra) {
        const clase = claseDePalabra.get(palabra) || "k-i";
        html += `<span class="${clase}">${escapar(palabra)}</span>`;
      } else if (espacio) html += espacio;
      else html += `<span class="k-g">${escapar(todo)}</span>`;
    }
    return html;
  };

  const patronRi = /(@\d+:\d+-\d+:\d+)|("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')|(%\d+)|(\bb\d+\(\))|(\b(?:[a-z_]+\.[a-z0-9_.]+|branch|jump|return|func|module)\b)|([A-Za-z0-9_]+|\s+|.)/g;
  const clasesRi = [null, "pos", "lit", "reg", "blq", "op"];

  const resaltarRi = (linea) => {
    let html = "";
    for (const m of linea.matchAll(patronRi)) {
      const indice = m.findIndex((grupo, i) => i > 0 && grupo !== undefined);
      const clase = clasesRi[indice];
      html += clase ? `<span class="${clase}">${escapar(m[0])}</span>` : escapar(m[0]);
    }
    return html;
  };

  const lineasDe = (elemento) => elemento.textContent.replace(/^\n/, "").replace(/\s+$/, "").split("\n");

  document.querySelectorAll("pre.pseudo").forEach((pre) => {
    const marcadas = new Set((pre.dataset.marcar || "").split(",").filter(Boolean).map(Number));
    const lineas = lineasDe(pre);
    if (pre.classList.contains("numerado")) {
      pre.innerHTML = lineas
        .map((l, i) => `<span class="ln${marcadas.has(i + 1) ? " marcada" : ""}">${resaltarLinea(l) || " "}</span>`)
        .join("");
    } else {
      pre.innerHTML = lineas.map(resaltarLinea).join("\n");
    }
  });

  document.querySelectorAll("pre.ri").forEach((pre) => {
    const marcadas = new Set((pre.dataset.marcar || "").split(",").filter(Boolean).map(Number));
    pre.innerHTML = lineasDe(pre)
      .map((l, i) => (marcadas.has(i + 1) ? `<span class="marca-ri">${resaltarRi(l)}</span>` : resaltarRi(l)))
      .join("\n");
  });

  document.querySelectorAll("code.pl").forEach((code) => {
    code.innerHTML = resaltarLinea(code.textContent);
  });

  document.querySelectorAll(".programa button[data-copiar]").forEach((boton) => {
    boton.addEventListener("click", async () => {
      const pre = boton.closest(".programa").querySelector("pre.pseudo");
      const texto = [...pre.querySelectorAll(".ln")].map((l) => l.textContent).join("\n") || pre.textContent;
      try {
        await navigator.clipboard.writeText(texto);
        boton.textContent = "Copiado";
      } catch {
        boton.textContent = "No se pudo copiar";
      }
      setTimeout(() => (boton.textContent = "Probar en el editor"), 1600);
    });
  });

  document.querySelectorAll("figure[data-pasos]").forEach((figura) => {
    const total = Number(figura.dataset.pasos);
    const textos = [...figura.querySelectorAll(".textos-pasos li")].map((li) => li.innerHTML);
    const elementos = [...figura.querySelectorAll("[data-paso]")];
    const anterior = figura.querySelector("[data-accion=anterior]");
    const siguiente = figura.querySelector("[data-accion=siguiente]");
    const contador = figura.querySelector(".contador");
    const caja = figura.querySelector(".pasos-texto");
    let actual = 1;
    const pintar = () => {
      for (const el of elementos) {
        const desde = Number(el.dataset.paso);
        const hasta = el.dataset.hasta ? Number(el.dataset.hasta) : Infinity;
        el.classList.toggle("oculto", !(desde <= actual && actual <= hasta));
      }
      anterior.disabled = actual === 1;
      siguiente.disabled = actual === total;
      contador.textContent = `Paso ${actual} de ${total}`;
      caja.innerHTML = textos[actual - 1] || "";
      caja.querySelectorAll("code.pl").forEach((c) => (c.innerHTML = resaltarLinea(c.textContent)));
    };
    anterior.addEventListener("click", () => { if (actual > 1) { actual -= 1; pintar(); } });
    siguiente.addEventListener("click", () => { if (actual < total) { actual += 1; pintar(); } });
    pintar();
  });
})();
