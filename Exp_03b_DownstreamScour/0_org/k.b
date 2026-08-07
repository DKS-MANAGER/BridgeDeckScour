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

internalField   #codeStream
{
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
        const IOdictionary& d = static_cast<const IOdictionary&>(dict);
        const fvMesh& mesh = refCast<const fvMesh>(d.db());
        scalarField k(mesh.nCells(), 1e-9);
        forAll(mesh.C(), cellI)
        {
            if (mesh.C()[cellI].y() >= 0.0)
            {
                k[cellI] = 1.98375e-4;
            }
        }
        k.writeEntry("", os);
    #};
};

boundaryField
{
    inlet
    {
        type            codedFixedValue;
        value           uniform 1.98375e-4;
        name            inlet_k_profile_03b;
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
            scalarField& field = *this;
            scalar t = this->db().time().value();
            scalar factor = (t <= 2.0) ? (t/2.0)*(t/2.0) : 1.0;
            forAll(Cf, faceI)
            {
                if (Cf[faceI].y() >= 0.0)
                {
                    field[faceI] = factor * 1.98375e-4;
                }
                else
                {
                    field[faceI] = 1e-9;
                }
            }
        #};
    }
    outlet
    {
        type            zeroGradient;
    }
    bottom
    {
        type            kqRWallFunction;
        value           uniform 2.5e-3;
    }
    top
    {
        type            kqRWallFunction;
        value           uniform 1.98375e-4;
    }
    bridgeDeck
    {
        type            kqRWallFunction;
        value           uniform 1.98375e-4;
    }
    deckSides
    {
        type            kqRWallFunction;
        value           uniform 1.98375e-4;
    }
    frontAndBack
    {
        type            empty;
    }
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
