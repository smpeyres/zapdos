//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADIntegratedBC.h"

// This boundary condition should only be used with species whose values are in the log-molar form

class LogDiffusionFluxBC : public ADIntegratedBC
{
public:
  static InputParameters validParams();

  LogDiffusionFluxBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  Real _r_units;

  Real _value;

  const ADMaterialProperty<Real> & _diffusivity;
  ADMaterialProperty<Real> _user_diff;

};