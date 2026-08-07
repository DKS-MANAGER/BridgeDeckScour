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
        scalarField omega(mesh.nCells(), 500.0);
        forAll(mesh.C(), cellI)
        {
            if (mesh.C()[cellI].y() >= 0.0)
            {
                omega[cellI] = 3.06;
            }
            else
            {
                omega[cellI] = 500.0;
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
        value           uniform 3.06;
        name            inlet_omega_profile_01a;
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
            scalar factor = (t <= 2.0) ? (t/2.0) : 1.0;
            forAll(Cf, faceI)
            {
                if (Cf[faceI].y() >= 0.0)
                {
                    field[faceI] = factor * 3.06 + 1e-3;
                }
                else
                {
                    field[faceI] = 500.0;
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
        type            omegaWallFunction;
        value           uniform 500.0;
        kn              0.00053;
    }
    top
    {
        type            omegaWallFunction;
        value           uniform 10.0;
        kn              0.536e-5;
    }
    bridgeDeck
    {
        type            omegaWallFunction;
        value           uniform 10.0;
        kn              0.536e-5;
    }
    deckSides
    {
        type            omegaWallFunction;
        value           uniform 10.0;
        kn              0.536e-5;
    }
    frontAndBack
    {
        type            empty;
    }
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
