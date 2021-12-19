# Práctica github actions

[![Cypress.io](https://img.shields.io/badge/tested%20with-Cypress-04C38E.svg)](https://www.cypress.io/)


### Qué es github actions?
GitHub Actions es una herramienta que permite reducir la cadena de acciones necesarias para la ejecución de código, mediante la creación de un workflow responsable del Pipeline. Siendo configurable para que GitHub reaccione ante determinados eventos de forma automática según nuestras preferencias.

Por lo tanto, GitHub Actions le permite crear flujos de trabajo que se pueden usar para compilar, probar e implementar código. Además, brinda la posibilidad de crear flujos de integración y despliegue continuo dentro de nuestro repositorio.

![ghActions](https://img2.storyblok.com/672x0/f/79165/1200x630/ebb5571e69/github-action-01.png)

Actions usa paquetes de código en contenedores Docker, que se ejecutan en servidores GitHub y que, a su vez, son compatibles con cualquier lenguaje de programación. Esto hace que se ejecuten en servidores locales y nubes públicas.


## Preparación del linter

```yaml
Linter_job:
  name: Linter job
  runs-on: ubuntu-latest

  steps:
    - name: Check out Git repository
      uses: actions/checkout@v2

    # Install your linters here
    - name: Run linters
      run: npm install && npm run lint
```

* El primer step se encarga de descargar el codigo fuente
* El segundo step se encargará de preparar el proyecto y iniciar el script lint verificando si el código de nuestra aplicación esta correctamente

Para solucionar los errores automáticamente del lint hay que ejecutar el siguiente comando. (Si sigue dando error se tiene que solucionar manualmente)
```console
~/ghActions-Practica $ ./node_modules/.bin/next lint --fix
```


