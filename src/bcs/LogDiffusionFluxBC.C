//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "LogDiffusionFluxBC.h"
#include "Function.h"
#include "MooseTypes.h"

registerMooseObject("ZapdosApp", LogDiffusionFluxBC);

// Building this base on ADVectorFunctionNeumannBC
InputParameters
LogDiffusionFluxBC::validParams()
{
  InputParameters params = ADVectorIntegratedBC::validParams();
  params.addParam<FunctionName>("function_x", 0, "The function for the x component");
  params.addParam<FunctionName>("function_y", 0, "The function for the y component");
  params.addParam<FunctionName>("function_z", 0, "The function for the z component");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addParam<Real>("diff", "The diffusivity.");
  params.addParam<bool>("use_material_props", true, "Whether to use a material for properties.");
  params.addClassDescription("Boundary condition where flux vector at boundary is user-prescribed in "
                               "particles per unit area per unit time.");
    
  return params;
}

LogDiffusionFluxBC::LogDiffusionFluxBC(const InputParameters & parameters)
  : ADVectorIntegratedBC(parameters),
    
    _r_units(1. / getParam<Real>("position_units")),

    _diffusivity(getParam<bool>("use_material_props")
                     ? getADMaterialProperty<Real>("diff" + _var.name())
                     : _user_diff),

    _function_x(getFunction("function_x")),
    _function_y(getFunction("function_y")),
    _function_z(getFunction("function_z"))
{ 
}

ADReal
LogDiffusionFluxBC::computeQpResidual()
{
  ADRealVectorValue func_vec = {_function_x.value(_t, _q_point[_qp]),
                                _function_y.value(_t, _q_point[_qp]),
                                _function_z.value(_t, _q_point[_qp])};
  
  
  return -_test[_i][_qp] * _r_units * _r_units * _diffusivity[_qp] * std::exp(_u[_qp]) * 
         6.022e23 * _normals[_qp] * _grad_u[_qp] - _test[_i][_qp] * _normals[_qp] * func_vec;
}