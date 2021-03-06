{-#LANGUAGE RankNTypes #-}
module Streaming 
   (
   -- * Free monad transformer
   -- $stream
   Stream, 
   -- * Constructing a 'Stream' on a base functor
   unfold,
   construct,
   for,
   layer,
   layers,
   replicates,
   repeats,
   repeatsM,
   delay,
   wrap,
   
   -- * Transforming streams
   decompose,
   maps,
   mapsM,
   distribute,
   eithers,
   
   -- * Inspecting a stream
   inspect,
   
   -- * Zipping streams
   zips,
   zipsWith,
   interleaves,
   
   -- * Eliminating a 'Stream'
   iterTM,
   iterT,
   destroy,
   mapsM_,
   run,

   -- * Splitting and joining 'Stream's 
   splitsAt,
   takes,
   chunksOf,
   concats,
   intercalates,
   
   -- * Base functor for streams of individual items
   Of (..),
   lazily,
   strictly,
   
   -- * re-exports
   MFunctor(..),
   MMonad(..),
   MonadTrans(..),
   MonadIO(..),
   Compose(..),
   join,
   liftA2,
   liftA3,
   void,
   )
   where
import Streaming.Internal 
import Streaming.Prelude 
import Control.Monad.Morph
import Control.Monad
import Control.Applicative
import Control.Monad.Trans
import Data.Functor.Compose 

{- $stream

    The 'Stream' data type is equivalent to @FreeT@ and can represent any effectful
    succession of steps, where the form of the steps or 'commands' is 
    specified by the first (functor) parameter. The present module exports
    functions that pertain to that general case. So for example, if the
    functor is 

    > data Split r = Split r r

    The @Stream Split m r@ will the type of binary trees with @r@ at the leaves
    and in which each episode of branching results from an @m@-effect. 
    


    In the simplest case, the base functor is @ (,) a @. Here the news 
    or /command/ at each step is an /individual element of type/ @ a @, 
    i.e. the command is a @yield@ statement.  The associated 
    @Streaming@ 'Streaming.Prelude' 
    uses the left-strict pair @Of a b@ in place of the Haskell pair @(a,b)@ 


and operations like e.g. 

> chunksOf :: Monad m => Int -> Stream f m r -> Stream (Stream f m) m r
> mapsM Streaming.Prelude.length' :: Stream (Stream (Of a) m) r -> Stream (Of Int) m r

-}

{-| Map a stream to its church encoding; compare @Data.List.foldr@
    This is the @safe_destroy@ exported by the @Internal@ module.

    Typical @FreeT@ operators can be defined in terms of @destroy@
    e.g.

> iterT :: (Functor f, Monad m) => (f (m a) -> m a) -> Stream f m a -> m a
> iterT out stream = destroy stream out join return
> iterTM ::  (Functor f, Monad m, MonadTrans t, Monad (t m)) => (f (t m a) -> t m a) -> Stream f m a -> t m a
> iterTM out stream = destroy stream out (join . lift) return
> concats :: (Monad m, MonadTrans t, Monad (t m)) => Stream (t m) m a -> t m a
> concats stream = destroy stream join (join . lift) return
-}


