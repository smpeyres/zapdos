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

registerMooseObject("ZapdosApp", LogDiffusionFluxBC);

InputParameters
LogDiffusionFluxBC::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<Real>("value", "Value of the BC.");
  params.addParam<Real>("diff", "The diffusivity.");
  params.addParam<bool>("use_material_props", true, "Whether to use a material for properties.");
  params.addClassDescription("Boundary condition where flux at boundary is user-prescribed in "
                               "particles per unit area per unit time.");
    
  return params;
}

LogDiffusionFluxBC::LogDiffusionFluxBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters),
    
    _r_units(1. / getParam<Real>("position_units")),

    _diffusivity(getParam<bool>("use_material_props")
                     ? getADMaterialProperty<Real>("diff" + _var.name())
                     : _user_diff),

    _value(getParam<Real>("value"))

{ 
}

ADReal
LogDiffusionFluxBC::computeQpResidual()
{
  return -_test[_i][_qp] * _r_units * _r_units * _diffusivity[_qp] * std::exp(_u[_qp]) * 
         6.022e23 * _normals[_qp] * _grad_u[_qp] - _normals[_qp] * _value;
}