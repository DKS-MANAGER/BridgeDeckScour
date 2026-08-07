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
    object      k.b;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

dimensions      [0 2 -2 0 0 0 0];

internalField   uniform 8.0e-4;

boundaryField
{
    inlet
    {
        type            fixedValue;
        value           uniform 0.000198375;
    }
    outlet
    {
        type            zeroGradient;
    }
    bottom
    {
        type            kqRWallFunction;
        value           uniform 0.000198375;
    }
    top
    {
        type            slip;
    }
    bridgeDeck
    {
        type            kqRWallFunction;
        value           uniform 0.000198375;
    }
    deckSides
    {
        type            kqRWallFunction;
        value           uniform 0.000198375;
    }
    frontAndBack
    {
        type            empty;
    }
}
