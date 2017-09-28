module Utils
    ( mapM
    , mapWithIndexM
    , mapMapM
    , mapStrMapM
    , mapMaybeM
    , sortByKeyM
    , sortByKey
    , lookupOrDefault
    , bisectFor_
    , forEnumerated_
    , forStrMap_
    , forMapM
    , forMapM_
    ) where

import Prelude

import Data.Array as A
import Data.List (List)
import Data.List as L
import Data.Map (Map)
import Data.Map as M
import Data.Maybe (Maybe(..), maybe)
import Data.StrMap (StrMap)
import Data.StrMap as SM
import Data.Traversable (class Traversable, for_, traverse)
import Data.Tuple (Tuple(..))
import Data.FunctorWithIndex (class FunctorWithIndex, mapWithIndex)

mapM :: forall m a b t. Applicative m => Traversable t => (a -> m b) -> t a -> m (t b)
mapM = traverse

mapWithIndexM :: forall m a b f i. Applicative m => FunctorWithIndex i f => Traversable f => (i -> a -> m b) -> f a -> m (f b)
mapWithIndexM f l =
    mapM (\(Tuple i x) -> f i x) $ mapWithIndex Tuple l

bisectFor_ :: forall m a. Monad m => Array a -> (a -> m Unit) -> m Unit
bisectFor_ arr f =
    let l = A.length arr
    in if l < 100 then
        for_ arr f
    else
        let n = l / 2
            firstHalf = A.take n arr
            secondHalf = A.drop n arr
        in do
            for_ firstHalf f
            for_ secondHalf f

forMapM :: forall a v k m. Monad m => Ord k => Map k v -> (k -> v -> m a) -> m (Map k a)
forMapM = flip mapMapM

forMapM_ :: forall a v k m. Monad m => Ord k => Map k v -> (k -> v -> m a) -> m Unit
forMapM_ m f = do
    _ <- forMapM m f
    pure unit

mapMapM :: forall m k v w. Monad m => Ord k  => (k -> v -> m w) -> Map k v -> m (Map k w)
mapMapM f m = do
    arr <- mapM mapper (M.toUnfoldable m :: Array (Tuple k v))
    pure $ M.fromFoldable arr
    where
        mapper (Tuple a b) = do
            c <- f a b
            pure $ Tuple a c

mapStrMapM :: forall m v w. Monad m => (String -> v -> m w) -> StrMap v -> m (StrMap w)
mapStrMapM f m = do
    arr <- mapM mapper (SM.toUnfoldable m :: Array (Tuple String v))
    pure $ SM.fromFoldable arr
    where
        mapper (Tuple a b) = do
            c <- f a b
            pure $ Tuple a c

mapMaybeM :: forall m a b. Monad m => (a -> m b) -> Maybe a -> m (Maybe b)
mapMaybeM f (Just x) = Just <$> f x
mapMaybeM _ _ = pure Nothing

sortByKey :: forall a b. Ord b => (a -> b) -> List a -> List a
sortByKey keyF = L.sortBy (\a b -> compare (keyF a) (keyF b))

sortByKeyM :: forall a b m. Ord b => Monad m => (a -> m b) -> List a -> m (List a)
sortByKeyM keyF items = do
    itemsWithKeys <- mapM (\item -> keyF item >>= (\key -> pure $ { item, key })) items
    let sortedItemsWithKeys = L.sortBy (\a b -> compare a.key b.key) itemsWithKeys
    pure $ map (_.item) sortedItemsWithKeys

lookupOrDefault :: forall k v. Ord k => v -> k -> Map k v -> v
lookupOrDefault default key m = maybe default id $ M.lookup key m

forEnumerated_ :: forall a b m. Applicative m => List a -> (Int -> a -> m b) -> m Unit
forEnumerated_ l f =
    let lWithIndexes = L.zip (L.range 0 ((L.length l) - 1)) l
    in
        for_ lWithIndexes \(Tuple i x) -> f i x

forStrMap_ :: forall a b m. Applicative m => StrMap a -> (String -> a -> m b) -> m Unit
forStrMap_ sm f =
    let arr = SM.toUnfoldable sm :: Array (Tuple String a)
    in
        for_ arr \(Tuple n v) -> f n v
