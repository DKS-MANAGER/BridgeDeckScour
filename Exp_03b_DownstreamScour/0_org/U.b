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
    class       volVectorField;
    object      U.b;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

dimensions      [0 1 -1 0 0 0 0];

internalField   uniform (0 0 0);

boundaryField
{
    inlet
    {
        type            codedFixedValue;
        value           uniform (0 0 0);
        name            inlet_profile_03b;
        codeInclude
        #{
            #include "fvCFD.H"
        #};
        codeOptions
        #{
            -I$(LIB_SRC)/finiteVolume/lnInclude \
            -I$(LIB_SRC)/meshTools/lnInclude
        #};
        codeLibs
        #{
            -lfiniteVolume \
            -lmeshTools
        #};
        code
        #{
            const fvPatch& boundaryPatch = patch();
            const vectorField& Cf = boundaryPatch.Cf();
            vectorField& field = *this;
            scalar t = this->db().time().value();
            scalar factor = (t <= 2.0) ? (t/2.0) : 1.0;
            forAll(Cf, faceI)
            {
                scalar y = Cf[faceI].y();
                if (y >= 0.0)
                {
                    scalar y0 = 1e-4;
                    if (y > y0)
                    {
                        field[faceI] = vector(factor * 0.23 * log(y/y0)/log(0.1107/y0), 0, 0);
                    }
                    else
                    {
                        field[faceI] = vector(0, 0, 0);
                    }
                }
                else
                {
                    field[faceI] = vector(0, 0, 0);
                }
            }
        #};
    }
    outlet
    {
        type            inletOutlet;
        inletValue      uniform (0 0 0);
        value           uniform (0 0 0);
    }
    bottom
    {
        type            fixedValue;
        value           uniform (0 0 0);
    }
    top
    {
        type            slip;
    }
    bridgeDeck
    {
        type            fixedValue;
        value           uniform (0 0 0);
    }
    deckSides
    {
        type            fixedValue;
        value           uniform (0 0 0);
    }
    frontAndBack
    {
        type            empty;
    }
}
