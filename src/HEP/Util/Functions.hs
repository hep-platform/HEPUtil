{-# LANGUAGE BangPatterns #-}

module HEP.Util.Functions 
  ( 
  -- * Some missing mathematical functions and useful functions
    sqr
  , cot
  , csc
  , fst3
  , snd3
  , trd3 
 
  -- * Four-momentum and basic operation
  , FourMomentum
  , energy
  , px 
  , py
  , pz 
  , plus
  , neg
  , subtract
  , dot4
  , sqr4
  , mom_2_pt_eta_phi
  , fourmomfrometaphipt

  -- * Angle dependent function
  , etatocosth
  , costhtoeta
  , deltaR

  -- * Invariant Mass 
  , invmasssqr
  , invmasssqr0
  , invmass
  , invmass0 

  -- * Lorentz Transformation 
  , LorentzRotation
  , LorentzVector
  , Vector3
  , fourMomentumToLorentzVector
  , vector3 
  , beta 
  , boost 
  , toRest
  , cosangle3
  , cosangle
  , cosTH

  -- * Cross section conversion
  , xsecConvGeV2Pb

  -- * alpha_S conversion
  , alphaStoGS

  ) where

import Prelude hiding (subtract)
import Numeric.LinearAlgebra

-- | FourMomentum is a type synonym of (E,px,py,pz)
type FourMomentum = (Double,Double,Double,Double) 
 
plus :: FourMomentum -> FourMomentum -> FourMomentum 
plus (t1,x1,y1,z1) (t2,x2,y2,z2) = (t1+t2,x1+x2,y1+y2,z1+z2)

neg :: FourMomentum -> FourMomentum 
neg (t1,x1,y1,z1) = ((-t1),(-x1),(-y1),(-z1))

subtract :: FourMomentum -> FourMomentum -> FourMomentum 
subtract p1 p2 = plus p1 (neg p2) 

sqr :: (Num a) => a -> a   
sqr x = x*x

energy :: (Double,Double,Double,Double) -> Double
energy (a,_,_,_) = a

px :: (Double,Double,Double,Double) -> Double
px     (_,a,_,_) = a

py :: (Double,Double,Double,Double) -> Double
py     (_,_,a,_) = a 

pz :: (Double,Double,Double,Double) -> Double
pz     (_,_,_,a) = a

dot4 :: FourMomentum -> FourMomentum -> Double 
dot4 (!t1,!x1,!y1,!z1) (!t2,!x2,!y2,!z2) = t1*t2 - x1*x2 - y1*y2 - z1*z2

sqr4 :: FourMomentum -> Double 
sqr4 p = dot4 p p 


cot :: Double -> Double
cot !x = 1.0 / tan x

csc :: Double -> Double
csc !x = 1.0 / sin x


etatocosth :: Double -> Double 
etatocosth !et =  ( exp (2.0 * et) - 1 ) / (exp (2.0 * et) + 1 )

costhtoeta :: Double -> Double
costhtoeta !costh =  0.5 * log ( ( 1 + costh ) / ( 1 - costh ) )  


mom_2_pt_eta_phi :: FourMomentum -> (Double,Double,Double)
mom_2_pt_eta_phi (_,!x,!y,!z) = 
  let pt = sqrt $ x^(2::Int) + y^(2::Int)
      costh = z / ( sqrt $ x^(2::Int) + y^(2::Int) + z^(2::Int) )
      phi' = atan $ y / x 
      phi'' | x > 0 = phi'  
            | otherwise = phi' + pi 
      phi''' | phi'' < 0  = phi'' + 2.0 * pi
             | otherwise = phi'' 
  in (pt, costhtoeta costh, phi''' ) 

deltaR :: (Double,Double,Double) -> (Double,Double,Double) -> Double
deltaR (_,!eta1,!phi1) (_,!eta2,!phi2) = sqrt $ (eta1-eta2)^(2::Int) + (phi1-phi2)^(2::Int) 

fst3 :: (a,b,c) -> a
fst3 (a,_,_) = a

snd3 :: (a,b,c) -> b
snd3 (_,a,_) = a

trd3 :: (a,b,c) -> c
trd3 (_,_,a) = a 


fourmomfrometaphipt :: (Double,Double,Double) -> FourMomentum
fourmomfrometaphipt !etaphipt = (p0, p1, p2, p3 )
  where eta' = fst3 etaphipt 
        phi' = snd3 etaphipt
        pt'  = trd3 etaphipt
        costh = etatocosth eta'
        sinth = sqrt (1 - costh*costh)
        p1  = pt' * cos phi' 
        p2  = pt' * sin phi'
        p3  = pt' * costh / sinth 
        p0  = pt' / sinth


invmasssqr :: FourMomentum -> FourMomentum -> Double
invmasssqr !mom1 !mom2 = dot4 mom1 mom1 + dot4 mom2 mom2 
                         + invmasssqr0 mom1 mom2

-- | for massless particle
invmasssqr0 :: FourMomentum -> FourMomentum -> Double
invmasssqr0 !mom1 !mom2 = 2.0 * dot4 mom1 mom2

invmass :: FourMomentum -> FourMomentum -> Double
invmass !mom1 !mom2 = sqrt $! invmasssqr mom1 mom2

-- | for massless particle 
invmass0 :: FourMomentum -> FourMomentum -> Double
invmass0 !mom1 !mom2 = sqrt $! invmasssqr0 mom1 mom2


-------------------------------------------

type LorentzRotation = Matrix Double

type LorentzVector = Vector Double

fourMomentumToLorentzVector :: FourMomentum -> LorentzVector 
fourMomentumToLorentzVector (v0,v1,v2,v3) = 4 |> [v0,v1,v2,v3]

type Vector3 = Vector Double

vector3 :: LorentzVector -> Vector3
vector3 v = 3 |> [v1,v2,v3]
    where [_,v1,v2,v3] = toList v

beta  :: LorentzVector -> Vector3
beta v = 3 |> [b1,b2,b3]
    where [v0,v1,v2,v3] = toList v
          b1 = v1/v0
          b2 = v2/v0
          b3 = v3/v0

boost :: Vector3 -> LorentzRotation
boost b = (4><4) [ ga    , -bx*ga           , -by*ga           , -bz*ga
                 , -bx*ga, 1+(ga-1)*bx*bx/b2, (ga-1)*bx*by/b2  , (ga-1)*bx*bz/b2
                 , -by*ga, (ga-1)*by*bx/b2  , 1+(ga-1)*by*by/b2, (ga-1)*by*bz/b2
                 , -bz*ga, (ga-1)*bz*bx/b2  , (ga-1)*bz*by/b2  , 1+(ga-1)*bz*bz/b2 ]
    where bx = b @> 0
          by = b @> 1
          bz = b @> 2 
          b2 = bx*bx+by*by+bz*bz
          ga = 1 / sqrt (1-b2)

toRest :: LorentzVector -> LorentzRotation
toRest = boost . beta 


cosangle3 :: Vector3 -> Vector3 -> Double
cosangle3 v1 v2 = v1 <.> v2 / (normv1 * normv2)
    where normv1 = sqrt $ v1 <.> v1
          normv2 = sqrt $ v2 <.> v2

cosangle :: LorentzVector -> LorentzVector -> Double
cosangle v1 v2 = cosangle3 (vector3 v1) (vector3 v2)

data EvenOdd = Even | Odd 

cosTH :: EvenOdd -> LorentzVector -> LorentzVector -> Double 
cosTH n v1 v2 = let vsum = v1 + v2
                    torestsum = toRest vsum
                    restv1 = torestsum <> v1
                    restv2 = torestsum <> v2
                    cosTH1 = cosangle vsum restv1
                    cosTH2 = cosangle vsum restv2 
                in  case n of 
                      Even -> cosTH2
                      Odd  -> cosTH1


xsecConvGeV2Pb :: Double -> Double 
xsecConvGeV2Pb gev = gev * 3.894e8


alphaStoGS :: Double -> Double 
alphaStoGS alphas = sqrt ( 4.0 * pi * alphas )  
  