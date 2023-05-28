// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

library Lagrange_cha {

    function array_mul(int256 front, int256[] calldata x_array, uint256 point) public returns (int256 tmp) { 
        int256 subr;
        int256 r = 1;
        for (uint256 p = 0; p < x_array.length; p++) {
            if (p==point){
                r = 1 * r;
            } else{
                subr = front - x_array[p];
                r = r * subr;
            }
            
        }
        return r;
    }

    function y_mul_array(int256[] calldata y,int256[] memory lagrange_array) public returns(int256 result){
        int256 tmp = 0;
        for (uint256 p = 0; p < lagrange_array.length; p++) {
            tmp = tmp + y[p] * lagrange_array[p];
        }
        return tmp;
    }

    function lagrange(int256 pp, int256[] calldata xs, int256[] calldata ys) public returns (int256 result) {
        int256 sum = 0;
        for(uint256 p=0; p<xs.length; p++){
            int256 up;
            int256 down;
            up = array_mul(0, xs, p);
            down = array_mul(xs[p], xs, p);
            sum = sum + (up / down) * ys[p];
        }
        int256 tmp = sum%pp;
        if (tmp>0){
            return tmp;
        }else {
            return tmp+pp;   
        }
    }

}