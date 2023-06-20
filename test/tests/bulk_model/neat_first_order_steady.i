dom0Scale = 1.0

[GlobalParams]
  # offset = 20
  # cant use offset with the kernels used
  use_moles = true
  # converts density from #/m^3 to moles/m^3
  # mol/m^3 = mM
[]

[Mesh]
  type = GeneratedMesh
  nx = 1000
  xmax = 1e-6
  # boundary layer thickness of 1 um
  dim = 1
[]

[Problem]
  type = FEProblem
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  end_time = 10
  steady_state_detection = true
  automatic_scaling = true
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = newton
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu NONZERO 1.e-10'
  nl_rel_tol = 1e-7
  nl_abs_tol = 1e-7
  dtmin = 1e-15
  l_max_its = 20
  scheme = crank-nicolson
  [TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.4
    dt = 1e-11
    growth_factor = 1.2
    optimal_iterations = 30
  []
[]

[Outputs]
  perf_graph = true
  [out]
    type = Exodus
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Variables]
  [em]
  []
[]

[Kernels]
  [em_diffusion]
    type = CoeffDiffusion
    variable = em
    position_units = ${dom0Scale}
  []
  [em_sink]
    type = ReactionFirstOrderLog
    variable = Ar+
    # v is a constant density of 1e16 #/m^3 in mole-log form
    # (i.e v  = ln(1e16/6.022e23) = -17.9135)
    v = -17.9135
    _v_eq_u = false
    coefficient = 1
    reaction = FirstOrder
  []
[]

[AuxVariables]
  [x]
    order = CONSTANT
    family = MONOMIAL
  []
  [x_node]
  []
  [em_lin]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [x_l]
    type = Position
    variable = x
    position_units = ${dom0Scale}
  []
  [x_nl]
    type = Position
    variable = x_node
    position_units = ${dom0Scale}
  []
  [em_lin]
    type = DensityMoles
    variable = em_lin
    density_log = em
  []
[]

[BCs]
  [em_left]
    type = NeumannBC
    value = 0.0104
    # this is in moles/m2*s given a 1000 A/m2 current density
    # 0.0104 divided by the scale length, 1e-6
    # F = 96485
    variable = em
    boundary = left
  []
  # shouldnt need right boundary condition if default is flux = 0
[]

[ICs]
  [em_ic]
    type = ConstantIC
    variable = em
    value = -21
  []
[]

[Materials]
  [ADProps]
    type = ADGenericConstantMaterial
    prop_names = 'diffem'
    prop_values = '3.0e-10' # m2/s for ethylene glycol
  []
  [RegProps]
    type = GenericConstantMaterial
    prop_names = 'N_A'
    prop_values = '6.022e23'
  []
[]
