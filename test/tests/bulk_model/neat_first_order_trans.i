dom0Scale = 1e-6

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
  xmax = 1
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
  [em_time_deriv]
    type = ElectronTimeDerivative
    variable = em
  []
  [em_diffusion]
    type = CoeffDiffusion
    variable = em
    position_units = ${dom0Scale}
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
    value = 1.04e4
    # this is in moles/m2*s given a 1000 A/m2 current density
    # 0.0104 divided by the scale length, 1e-6
    # F = 96485
    variable = em
    boundary = left
  []
  [em_rightFix]
    type = DirichletBC
    value = -25
    variable = em
    boundary = right
    # pinning the right
  []
  [em_rightZeroFlux]
    type = NeumannBC
    value = 0
    variable = em
    boundary = right
    # pinning the right
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

[Reactions]
  [Liquid]
    species = 'em'
    use_log = true
    reaction_coefficient_format = 'rate'
    convert_to_moles = true
    position_units = ${dom0Scale}
    use_ad = true
    block = 0
    # 1/s -> corresponds to ethylene glycol
    reactions = 'em -> W : 4.5e5'
  []
[]