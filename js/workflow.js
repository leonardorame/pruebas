Un Workflow es un conjunto de step.

usar ui.router

En el evento stateChangeStart, debe verificarse
si es posible ir a un nuevo estado, en caso
afirmativo, verificar si el parámetro require_auth es true
y lanzar un diálogo de autenticación, y recién ahí permitir el 
cambio de estado.

workflow: [
  {
    step_name: "inicio",
    allowed_steps: [
      {
        step_name: "fin",
        require_auth: true
      }
    ]
  },
  {
    step_name: "fin",
    allowed_steps: [
      {
        step_name: "grabar",
        require_auth: true
      }
    ]
  },
  {
    step_name: "grabar",
    allowed_steps: [
      {
        step_name: "definitivo",
        require_auth: true
      }
    ]
  },
  {
    step_name: "definitivo",
    allowed_steps: [
      {
        step_name: "grabar",
        require_auth: false
      }
    ]
  }
]
