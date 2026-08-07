/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  v2412                                 |
|   \\  /    A nd           | Web:      www.openfoam.com                      |
|    \\/     M anipulation  | Exp-01a                                         |
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
        name            inlet_profile_01a;
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
                if (Cf[faceI].y() >= 0.0)
                {
                    // Smooth logarithmic boundary layer profile starting at 0 at y=0
                    scalar u = 0.23 * log(1.0 + 1000.0 * Cf[faceI].y()) / log(121.0);
                    field[faceI] = factor * vector(u, 0, 0);
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
        type            noSlip;
    }
    top
    {
        type            noSlip;
    }
    bridgeDeck
    {
        type            noSlip;
    }
    deckSides
    {
        type            noSlip;
    }
    frontAndBack
    {
        type            empty;
    }
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
