// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


import "./Lagrange.sol";

contract Omlytics {

    // contract status: 1 means beginning
    uint8 status = 1;

    // y^alpha and p
    int256 y;
    int256 y_alpha;
    int256[] p_array;

    // a server structure
    struct Server{
        int256[] g;
        int256[] g_plus;
        int256[] v_array;
        int256[] w_array;
        int256 A;
        int256 A_plus;
    }

    int256[] public xs;

    // invalid server list
    uint256[] public valid;

    // length and x array each time
    uint256 public serverLength;
    uint256 public valueLength;

    // Fx array
    int256[] public Fxs;


    // all server list
    mapping (uint256 => Server) public servers;
    mapping (uint256 => int256) public fxs;
    mapping (uint256 => int256) public alpha_fxs;

    // status 1: accept secret sharing of original gradient and MO deploy valid function
    function accounceValid(string memory validFunction, int256[][] memory gs) public returns (string memory message, string memory result){
        if (status == 1){

            // load some parameters
            serverLength = gs[0].length;
            valueLength = gs.length;
            
            // load xs
            for (uint256 p=0; p<serverLength; p++){
                xs.push(int(p+1));
            }

            // load gs
            for (uint256 p=0; p<serverLength; p++){
                for(uint256 j=0; j<valueLength; j++){
                    servers[p].g.push(gs[j][p]);
                }
            }

            status = 2;

            return ("succeed", validFunction);
        } else {
            return("failed", "failed to reveal valid function");
        }
    }
/**
    // status 2: accept g' and v, w, recover F(g) and check if it's valid
    function isValid(int256[][] memory v, int256[][] memory w, int256 y, int256[] memory p) public returns(bool ok, int256[] memory validGradients, string memory message){
        int256[] memory r1;
        int256[] memory r2;

        int256[] memory vv_array;
        int256[] memory ww_array;
        int256[] memory F_g;
        int256[] memory alpha_F_g;

        int256[] memory j_array;
        for (uint256 i=0; i<v[0].length; i++){
            j_array[i] = int(i);
        }

        // load the server's v and w info
        for (uint256 i=0; i<v.length; i++){
            servers[i].v_array = v[i];
        }


        for (uint256 i=0; i<w.length; i++){
            servers[i].w_array = w[i];
        }
    }
**/
    

    function recoverSecret(int256 pp, int256[] memory x_temp, int256[] memory v_temp) public returns (int256 secret){
        return Lagrange_cha.lagrange(pp, x_temp, v_temp);
    }

    function loadMVarrays(uint256 serverId, int256[] memory vs, int256[] memory ws) public {
        servers[serverId].v_array = vs;
        servers[serverId].w_array = ws;
    }

    function loadParrays(int256[] memory ps) public {
        p_array = ps;
    }

    function loadYs(int256 y1, int256 y_alpha1) public {
        y=y1;
        y_alpha = y_alpha1;
    }

    function recoverFx(uint256 valueId) public returns(int256 fx) {
        
        int256[] memory vs = new int256[](5);
        for(uint256 p=0; p<serverLength; p++){
            vs[p] = servers[p].v_array[valueId];
        }
        int256 fx = Lagrange_cha.lagrange(p_array[valueId], xs, vs);
        fxs[valueId] = fx;
        return fx;
    }

    function recoverAlphaFx(uint256 valueId) public returns(int256 AlphaFx) {
        
        int256[] memory ws = new int256[](5);
        for(uint256 p=0; p<serverLength; p++){
            ws[p] = servers[p].w_array[valueId];
        }
        int256 AlphaFx = Lagrange_cha.lagrange(p_array[valueId], xs, ws);
        alpha_fxs[valueId] = AlphaFx;
        return AlphaFx;
    }

    function validateMSVC(uint256 valueId, int256 v, int256 w, int256 q) public returns (bool validMSVC){
        int256 left = y**uint(w) % q;
        int256 right = y_alpha**uint(v) %q ;
        return left==right;
    }

    function validateA(int256 r3, int256 r4, int256 y_mul) public returns (bool validA){
        int256 left = y**uint(r4);
        int256 right = y_mul**uint(r3) ;
        return left==right;
    }

    function testExp(int256 t1, int256 t2, int256 t3, int256 t4) public returns (bool validornot, int256 rightnum){
        int256 q = 170141183460469231731687303715884105727;
        int256 left = t1**uint(t2) % q;
        int256 right = t3**uint(t4) % q;
        return (left==right,right);
    }

}