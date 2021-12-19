# Práctica github actions

[![Cypress.io](https://img.shields.io/badge/tested%20with-Cypress-04C38E.svg)](https://www.cypress.io/)


### Qué es github actions?
GitHub Actions es una herramienta que permite reducir la cadena de acciones necesarias para la ejecución de código, mediante la creación de un workflow responsable del Pipeline. Siendo configurable para que GitHub reaccione ante determinados eventos de forma automática según nuestras preferencias.

Por lo tanto, GitHub Actions le permite crear flujos de trabajo que se pueden usar para compilar, probar e implementar código. Además, brinda la posibilidad de crear flujos de integración y despliegue continuo dentro de nuestro repositorio.

![ghActions](https://img2.storyblok.com/672x0/f/79165/1200x630/ebb5571e69/github-action-01.png)

Actions usa paquetes de código en contenedores Docker, que se ejecutan en servidores GitHub y que, a su vez, son compatibles con cualquier lenguaje de programación. Esto hace que se ejecuten en servidores locales y nubes públicas.


## Preparación del linter

Fichero `.github/workflows/ghActions-Practica.yml`  
Nuevo job
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
* El segundo step se encarga de preparar el proyecto y iniciar el script lint verificando si el código de nuestra aplicación esta correctamente

Para solucionar los errores automáticamente del lint hay que ejecutar el siguiente comando. (Si sigue dando error se tiene que solucionar manualmente)
```console
~/ghActions-Practica $ ./node_modules/.bin/next lint --fix
```


## Preparación de cypress

Fichero `.github/workflows/ghActions-Practica.yml`  
Nuevo job
```yaml
Cypress_job:
  name: Cypress job
  runs-on: ubuntu-latest
  needs: Linter_job
  steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Cypress run
      uses: cypress-io/github-action@v2
      id: cypress
      continue-on-error: true
      with:
        config-file: cypress.json
        build: npm run build
        start: npm start
    
    - name: Outcome
      run: |
          echo ${{ steps.cypress.outcome }} > result.txt

    - name: Upload artifact
      uses: actions/upload-artifact@v2
      with:
        name: cypress-result
        path: result.txt
```

* El primer step se encarga de descargar el codigo fuente.
* El segundo se encarga de instalar nuestro proyecto y iniciarlo para luego ejecutar los tests de cypress, continue-on-error hará que continue los steps aunque de error, le ponemos id para obtener el resultado en el siguiente step.
* El tercero se encarga de obtener la salida del job anterior y guardarlo en result.txt.
* El ultimo step subirá el artefacto del fichero de la salida de cypress para obtenerlo en otro job.

## Preparación de badges
Fichero `.github/workflows/ghActions-Practica.yml`  
Nuevo job

```yaml
 Add_badge_job:
  name: Add badge job
  runs-on: ubuntu-latest
  needs: Cypress_job
  if: ${{ always() }}
  steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Download artifact
      uses: actions/download-artifact@v2
      with:
        name: cypress-result

    - name: Cypress output
      id: cypress-output
      run: echo "::set-output name=cypress_outcome::$(cat result.txt)"

    - uses: ./.github/actions/badges/
      with:
        cypress_outcome: ${{ steps.cypress-output.outputs.cypress_outcome }}

    - name: Commit
      run: |
        git config user.email "badgebot@github.com"
        git config user.name "badgebot"
        git add .
        git commit --allow-empty -m "Badges"
        git remote set-url origin https://iferrer20:${{ secrets.GITHUB_TOKEN }}@github.com/iferrer20/ghActions-Practica.git
        git push
```

Este job se ejecutara aunque los jobs anteriores fallen. Contiene los siguientes steps.
* El primer step se encarga de descargar el codigo fuente.
* EL segundo step se encarga de descargar el artefacto subido en el job anterior (results.txt).
* El tercero se encarga de establecer como salida el artefacto results.txt.
* El cuarto se encarga de ejecutar nuestro action badge, tiene un solo argumento que indica el status de cypress (si ha fallado o no).
* El ultimo step se encargará de subir los cambios hechos por nuestro badge al repositorio remoto.

### Action badges
Fichero `./.github/actions/badges/action.yml`
```yaml
name: 'Badges'
description: 'Set badges in readme file'
inputs:
  cypress_outcome:
    description: 'Cypress outcome'
    required: true
runs:
  using: "composite"
  steps:
    - run: python ${{ github.action_path }}/badges.py ${{ inputs.cypress_outcome }}
      shell: bash
```

Este action tomará como input cypress_outcome que indicará si cypress ha fallado o no, y será obligatorio.  
El action corre sobre composite que nos permite añadir steps y ejecutar python, ponemos shell bash para poder ejecutar el comando python sobre el script `badges.py` y le añadimos como argumento el cypress outcome

Fichero `./.github/actions/badges/badges.py`
```python
import sys
import re

content = open("README.md").read()
f = open("README.md", "w")
f.write(
    re.sub('tested%20with-Cypress-04C38E|tested%20with-Cypress-04C38E', 'tested%20with-Cypress-04C38E' if sys.argv[1] == "success" else 'tested%20with-Cypress-04C38E', content)
)
f.close()
```

Dependiendo de si el primer argumento es success, el script substituirá el uri que indica el tipo de badge, y lo guardará al README.md


