{-# LANGUAGE DataKinds #-}
module Diff.Spec where

import Category
import Data.Record
import Data.Text.Arbitrary ()
import qualified Data.Vector as Vector
import Diff
import Diff.Arbitrary
import Interpreter
import Prologue
import Term.Arbitrary
import Test.Hspec
import Test.Hspec.QuickCheck
import Test.QuickCheck

spec :: Spec
spec = parallel $ do
  prop "equality is reflexive" $
    \ a b -> let diff = diffTerms wrap (==) diffCost (toTerm a) (toTerm (b :: ArbitraryTerm Text (Record '[Vector.Vector Double, Category]))) in
      diff `shouldBe` diff

  prop "equal terms produce identity diffs" $
    \ a -> let term = toTerm (a :: ArbitraryTerm Text (Record '[Vector.Vector Double, Category])) in
      diffCost (diffTerms wrap (==) diffCost term term) `shouldBe` 0

  describe "beforeTerm" $ do
    prop "recovers the before term" $
      \ a b -> let diff = diffTerms wrap (==) diffCost (toTerm a) (toTerm (b :: ArbitraryTerm Text (Record '[Vector.Vector Double, Category]))) in
        beforeTerm diff `shouldBe` Just (toTerm a)

  describe "afterTerm" $ do
    prop "recovers the after term" $
      \ a b -> let diff = diffTerms wrap (==) diffCost (toTerm a) (toTerm (b :: ArbitraryTerm Text (Record '[Vector.Vector Double, Category]))) in
        afterTerm diff `shouldBe` Just (toTerm b)

  describe "ArbitraryDiff" $ do
    prop "generates diffs of a specific size" . forAll ((arbitrary >>= \ n -> (,) n <$> diffOfSize n) `suchThat` ((> 0) . fst)) $
      \ (n, diff) -> arbitraryDiffSize (diff :: ArbitraryDiff Text ()) `shouldBe` n


instance Arbitrary a => Arbitrary (Vector.Vector a) where
  arbitrary = Vector.fromList <$> listOf1 arbitrary
  shrink a = Vector.fromList <$> shrink (Vector.toList a)
