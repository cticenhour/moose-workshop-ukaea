[Mesh]
  [cmg]
    type = CartesianMeshGenerator
    dim = 3
    dx = 0.0334
    dy = '0.002 0.038 0.023 0.022 0.018 0.022'
    dz = 0.0366
    ix = 18
    iy = '2 10 10 22 10 22'
    iz = 10
    subdomain_id = '0 1 2 3 4 3'
  []
  [CH1_block]
    type = SubdomainBoundingBoxGenerator
    input = cmg
    bottom_left = '0.0067 0.0679 0'
    top_right = ' 0.0267 0.0779 0.0366'
    block_id = 5
  []
  [CH2_block]
    type = SubdomainBoundingBoxGenerator
    input = CH1_block
    bottom_left = '0.0067 0.1079 0'
    top_right = ' 0.0267 0.1179 0.0366'
    block_id = 6
  []
  [CH1]
    type = BlockDeletionGenerator
    input = CH2_block
    block = 5
    new_boundary = CH1
  []
  [CH2]
    type = BlockDeletionGenerator
    input = CH1
    block = 6
    new_boundary = CH2
  []
[]

[Outputs]
  exodus = true
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  dt = 1
  end_time = 30
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'hypre'
[]

[Variables]
  [T]
    initial_condition = 800 # K
  []
[]

[AuxVariables]
  [Tfluid]
    family = MONOMIAL
    order = CONSTANT
    initial_condition = 623
  []
  [htc]
    family = MONOMIAL
    order = CONSTANT
    initial_condition = 0
  []
[]

[Kernels]
  [conduction]
    type = HeatConduction
    variable = T
  []
  [time_derivative]
    type = HeatConductionTimeDerivative
    variable = T
  []
  [pd_shield]
    type = HeatSource
    variable = T
    block = 0
    value = 2.7544e+06
  []
  [pd_fw]
    type = HeatSource
    variable = T
    value = 4.6228e+05
    block = 1
  []
  [pd_mult]
    type = HeatSource
    variable = T
    value = 6.4374e+05
    block = 2
  []
  [pd_ts]
    type = HeatSource
    variable = T
    value = 6.3422e+05
    block = 3
  []
  [pd_breeder]
    type = HeatSource
    variable = T
    value = 1.6260e+06
    block = 4
  []
[]

[BCs]
  [FW_BC]
    type = NeumannBC
    variable = T
    boundary = 'bottom'
    value = 305.61 # 0.25 MW/m^2
  []
  #[channel]
    #type = DirichletBC
    #variable = T
    #boundary = 'CH1 CH2'
    #value = 620
  #[]
  [channel]
    type = CoupledConvectiveHeatFluxBC
    variable = T
    htc = htc
    T_infinity = Tfluid
    boundary = 'CH1 CH2'
  []
[]

[Materials]
  [breeder_material_BZ_conductivity]
    type = HeatConductionMaterial
    thermal_conductivity_temperature_function = breeder
    temp = T
    specific_heat = 249.6
    block = 4
  []
  [multiplier_material_BZ_conductivity]
    #First-principles calculations of mechanical and thermodynamic properties of tetragonal Be12Ti
    #X. Liu
    #Fig 11
    type = HeatConductionMaterial
    thermal_conductivity_temperature_function = multiplier
    temp = T
    specific_heat = 2083.33
    block = 2
  []
  [breeder_material_plate_conductivity]
    type = HeatConductionMaterial
    thermal_conductivity_temperature_function = F82H
    temp = T
    specific_heat = 700
    block = '1 3'
  []
  [armor_material_conductivity]
    type = HeatConductionMaterial
    thermal_conductivity_temperature_function = tungsten
    temp = T
    specific_heat = 145.0
    block = 0
  []
  [breeder_density]
    #http://qedfusion.org/LIB/PROPS/PANOS/li2zro3.html
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 4150
    block = 4
  []
  [multiplier_density]
    #First-principles investigation of the structural and elastic properties of Be12Ti under high pressure
    #X. Liu
    #Table 4
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 2310
    block = 2
  []
  [plate_density]
    #Physical properties of F82H for fusion blanket design
    #T. Hirose
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 7887
    block = '1 3'
  []
  [armor_density]
    #http://qedfusion.org/LIB/PROPS/PANOS/w.html
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 19300.0
    block = 0
  []
[]

[Functions]
  [./F82H]
    # Multiphyics modeling of the FW/Blanket of the US fusion nuclear science facility
    # Y. Huang,
    # Fig. 7
    type = PiecewiseLinear
    x = '293.93 390.03 491.33 592.63 696.53 779.64 865.36 943.28 1008.21 1067.96 1140.68' # K
    y = '24.46 23.04 21.33 19.24 16.77 14.49 11.93 9.37 6.80 4.34 1.30' # W/mK
  [../]
  [./breeder]
    # A Novel Cellular Breeding Material For Transformative Solid Breeder Blankets
    # S. Sharafat
    # Figure 18
    type = PiecewiseLinear
    x = '273.23 307.47 362.71 461.40 562.54 666.43 767.05 867.29 967.50 1070.53 1170.73 1268.15 1381.42 1480.19' # K
    y = '3.96 3.66 3.43 2.86 2.49 2.20 2.00 1.92 1.85 1.85 1.78 1.64 1.26 0.66' # W/mK
  [../]
  [./multiplier]
    # Thermal conductivity of neutron irradiated Be12Ti
    # M. Uchida
    # Fig. 6
    type = PiecewiseLinear
    x = '266.83 376.31 477.36 662.62 847.89 1049.99 1243.68' #K
    y = '12.96 18.31 19.44 22.82 25.07 32.96 50.42' # W/mK
  [../]
  [./tungsten]
    # Thermal properties of pure tungsten and its alloys for fusion applications
    # Makoto Fukuda
    # Fig. 5
    type = PiecewiseLinear
    x = '365.44 464.99 556.82 660.93 757.28 858.82 947.70 1115.15 1254.55 1343.22' #K
    y = '178.86 162.76 149.22 142.95 140.10 134.69 129.26 122.23 119.01 117.86' # W/mK
  [../] 
[]

[MultiApps]
  [channel1]
    type = FullSolveMultiApp
    app_type = ThermalHydraulicsApp
    input_files = CH1.i
    execute_on = 'TIMESTEP_END'
  []
  [channel2]
    type = FullSolveMultiApp
    app_type = ThermalHydraulicsApp
    input_files = CH2.i
    execute_on = 'TIMESTEP_END'
  []
[]

[CoupledHeatTransfers]
  [CH1]
    boundary = CH1
    T_fluid = 'Tfluid'
    T = T
    T_wall = T_wall
    htc = 'htc'
    multi_app = channel1
    T_fluid_user_objects = 'T_uo'
    htc_user_objects = 'Hw_uo'

    position = '0.0167 0.0747 0.0366'
    orientation = '0 0 -1'
    length = 0.0366
    n_elems = 9
    skip_coordinate_collapsing = true
  []

  [CH2]
    boundary = CH2
    T_fluid = 'Tfluid'
    T = T
    T_wall = T_wall
    htc = 'htc'
    multi_app = channel2
    T_fluid_user_objects = 'T_uo'
    htc_user_objects = 'Hw_uo'

    position = '0.0167 0.1133 0.0366'
    orientation = '0 0 -1'
    length = 0.0366
    n_elems = 9
    skip_coordinate_collapsing = true
  []
[]

