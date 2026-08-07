/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  v2412                                 |
|   \\  /    A nd           | Web:      www.openfoam.com                      |
|    \\/     M anipulation  | Exp-03b                                         |
\*---------------------------------------------------------------------------*/
FoamFile
{
    version     2.0;
    format      ascii;
    class       volScalarField;
    object      epsilon.b;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

dimensions      [0 2 -3 0 0 0 0];

internalField   uniform 3.825e-5;

boundaryField
{
    inlet
    {
        type            fixedValue;
        value           uniform 3.825e-5;
    }
    outlet
    {
        type            zeroGradient;
    }
    bottom
    {
        type            epsilonWallFunction;
        value           uniform 3.825e-5;
    }
    top
    {
        type            zeroGradient;
    }
    bridgeDeck
    {
        type            epsilonWallFunction;
        value           uniform 3.825e-5;
    }
    deckSides
    {
        type            epsilonWallFunction;
        value           uniform 3.825e-5;
    }
    frontAndBack
    {
        type            empty;
    }
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
