// un Workflow es un conjunto de step
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
