package main

import (
	"fmt"
	"github.com/posener/sharedsecret"
	"math/big"
	"time"
)

type Server struct {
	C sharedsecret.Share
	B sharedsecret.Share
	V sharedsecret.Share
	W sharedsecret.Share
}

// note: the secret sharing scheme package has been changed in some details: some private values have been transformed to public

func main() {

	start := time.Now() // 获取当前时间

	// first: KeyGen

	// assume k = 5, t = 2, 3 servers could recover secret
	// k := big.NewInt(5)
	F := NormBoundOne

	// second: ProbGen
	x := big.NewInt(2)
	alpha := big.NewInt(5)
	fmt.Println("x: ", x, "alpha: ", alpha)

	// share x and alpha
	shareX := CreateShares(x, 5, 1)
	fmt.Println("g shares:", shareX)
	shareAlpha := CreateShares(alpha, 5, 1)

	// g ** alpha mod q
	g := big.NewInt(29)
	q := big.NewInt(10019)
	GA := new(big.Int).Exp(g, alpha, q)

	// third: Compute
	fmt.Println("length of shareX: ", len(shareX))

	// construct each share of F(shareX)
	var V []sharedsecret.Share
	var v [5]*big.Int
	for i := 0; i < 5; i++ {
		v[i] = F(shareX[i].Y, big.NewInt(3))
	}
	fmt.Println("v array", v)
	for i := 0; i < 5; i++ {
		x := big.NewInt(int64(i + 1))
		y := v[i]
		y = new(big.Int).Mod(y, sharedsecret.Prime128Value())
		V = append(V, sharedsecret.Share{x, y})
	}

	// construct each share of mul(F(shareX) and shareAlpha)
	var W []sharedsecret.Share
	var w [5]*big.Int
	for i := 0; i < 5; i++ {

		w[i] = new(big.Int).Mul(v[i], shareAlpha[i].Y)
		w[i] = new(big.Int).Mod(w[i], sharedsecret.Prime128Value())
		x := big.NewInt(int64(i + 1))
		y := w[i]
		y = new(big.Int).Mod(y, sharedsecret.Prime128Value())
		W = append(W, sharedsecret.Share{x, y})
	}
	fmt.Println("w array", w)
	fmt.Println("y: ", g)
	fmt.Println("y_alpha: ", GA)
	fmt.Println("q: ", q)

	// forth: verify
	// recover Fx and alphaFx
	Fx := RecoverShares(V)
	fmt.Println("Fx: ", Fx)
	alphaFx := RecoverShares(W)
	fmt.Println("alphaFx: ", alphaFx)
	fmt.Println("GA: ", GA)

	// exp(gA, Fx), exp( g, alpha*F(x) )
	left := new(big.Int).Exp(GA, Fx, q)

	right := new(big.Int).Exp(g, alphaFx, q)

	fmt.Println("left: ", left)
	fmt.Println("right: ", right)

	finalTime := time.Since(start)
	fmt.Println("Total Cost：", finalTime)
}

// TestMult function F for msvc test
func TestMult(x *big.Int) *big.Int {

	return new(big.Int).Add(x, big.NewInt(2133))

}

func NormBoundOne(x *big.Int, v *big.Int) *big.Int {
	x3 := x
	//x3 = new(big.Int).Mod(x3, sharedsecret.Prime128Value())
	fmt.Println("x3", x3)
	sum := big.NewInt(1)
	i := big.NewInt(0)

	for v.Cmp(i) > 0 {
		i = i.Add(i, big.NewInt(1))
		sub1 := new(big.Int).Sub(x3, i)
		sum = new(big.Int).Mul(sum, sub1)
		//sum = new(big.Int).Mod(tmp, sharedsecret.Prime128Value())
		//fmt.Println("x3: ", x3, "i: ", i, "sub1: ", sub1, "sum: ", sum)
	}
	sum = new(big.Int).Mod(sum, sharedsecret.Prime128Value())
	sum = new(big.Int).Div(sum, x3)
	fmt.Println("sum: ", sum)
	return sum

	//if x3.Cmp(v) == 1 {
	//	return big.NewInt(1)
	//} else {
	//	return big.NewInt(0)
	//}
}

func NormBound(x *big.Int, v *big.Int) *big.Int {

	x2 := x

	if x2.Cmp(v) == 1 {
		return big.NewInt(0)
	} else {
		return big.NewInt(1)
	}
}

func NormBall(x []*big.Int, v *big.Int) *big.Int {
	sum := big.NewInt(0)
	for i := 0; i < len(x); i++ {
		x2 := new(big.Int).Mul(x[i], new(big.Int).Sub(x[i], v))
		sum = new(big.Int).Add(sum, x2)
	}
	return sum
}

func Zeno(x []*big.Int, u []*big.Int) *big.Int {
	sum := big.NewInt(0)
	for i := 0; i < len(x); i++ {
		x2 := new(big.Int).Mul(x[i], x[i])
		sum = new(big.Int).Add(sum, x2)
	}
	return sum
}
