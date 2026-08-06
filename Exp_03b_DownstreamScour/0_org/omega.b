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
        scalarField omega(mesh.nCells(), 50.0);
        forAll(mesh.C(), cellI)
        {
            if (mesh.C()[cellI].y() >= 0.0)
            {
                omega[cellI] = 3.06;
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
        name            inlet_omega_profile_03b;
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
                    field[faceI] = 1000.0;
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
    frontAndBack
    {
        type            empty;
    }
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
