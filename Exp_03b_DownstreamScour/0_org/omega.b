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
    object      omega.b;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

dimensions      [0 0 -1 0 0 0 0];

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
        scalarField omega(mesh.nCells(), 300.0);
        forAll(mesh.C(), cellI)
        {
            if (mesh.C()[cellI].y() >= 0.0)
            {
                omega[cellI] = 3.3;
            }
            else
            {
                omega[cellI] = 300.0;
            }
        }
        omega.writeEntry("", os);
    #};
};

boundaryField
{
    inlet
    {
        type            codedFixedValue;
        value           uniform 3.3;
        name            inlet_omega_03b;
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
            forAll(Cf, faceI)
            {
                if (Cf[faceI].y() >= 0.0)
                {
                    field[faceI] = 3.3;
                }
                else
                {
                    field[faceI] = 300.0;
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
        type            zeroGradient;
    }
    top
    {
        type            slip;
    }
    bridgeDeck
    {
        type            omegaWallFunction;
        value           uniform 300.0;
        kn              1e-5;
    }
    deckSides
    {
        type            omegaWallFunction;
        value           uniform 300.0;
        kn              1e-5;
    }
    frontAndBack
    {
        type            empty;
    }
}
