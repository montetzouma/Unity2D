-- | Utils for image processing.

{-# LANGUAGE Rank2Types #-}

module Visualise.Tools (
  -- * Sprite dimensions
  spriteHeight,
  spriteWidth,
  -- * Convenience wrappers
  fromDynamicImage',
  readImage',
  translate',
  -- * Image cropping
  cropDynamicImage,
  -- * Coordinate conversion
  positionToCoords,
  positionToCoords'
)
where

import Codec.Picture.Extra  (crop)
import Graphics.Gloss.Juicy (fromDynamicImage)

import qualified Apecs.Gloss   as AG
import qualified Codec.Picture as CP
import qualified Data.Maybe    as Maybe
import qualified Linear        as L

import qualified Components    as C


----------------------------------------------------------------------------------------------
-----------------------                SPRITE DIMENSIONS               -----------------------
----------------------------------------------------------------------------------------------
-- | Width and height of sprites in the sheet Scavengers_SpriteSheet.png
spriteWidth, spriteHeight :: Int
spriteWidth  = 32 
spriteHeight = 32
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
-----------------------              CONVENIENCE WRAPPERS              -----------------------
----------------------------------------------------------------------------------------------
-- | Unsafe version of JuicyPixels' Codec.Picture.readImage.
-- Throws an error if the image cannot be read.
readImage' :: FilePath -> IO CP.DynamicImage
readImage' filePath = do
  img <- CP.readImage filePath

  case img of  
    Left  e -> error e 
    Right i -> return i


-- | Unsafe version of Graphics.Gloss.Juicy.fromDynamicImage.
-- Throws an error if the conversion from DynamicImage to Gloss Picture is unsuccessful.
fromDynamicImage' :: CP.DynamicImage -> AG.Picture 
fromDynamicImage' img = Maybe.fromMaybe
  (error "fromDynamicImage':: Failed to convert DynamicImage to Picture!") 
  (fromDynamicImage img)


translate' :: AG.Point -> AG.Picture -> AG.Picture
translate' = uncurry AG.translate 
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
-----------------------                  IMAGE CROPPING                -----------------------
----------------------------------------------------------------------------------------------
-- | Crop a DynamicImage.
-- The origin is the top left of the image.
-- Copied from https://www.reddit.com/r/haskellquestions/comments/2imq14/how_do_i_load_sprites_from_a_sprite_sheet/.
cropDynamicImage :: Int -> Int -> Int -> Int -> CP.DynamicImage -> CP.DynamicImage
cropDynamicImage startX startY width height = withDynamicImage $ crop startX startY width height


-- | Apply a function to a DynamicImage.
-- Copied from https://www.reddit.com/r/haskellquestions/comments/2imq14/how_do_i_load_sprites_from_a_sprite_sheet/.
withDynamicImage :: (forall a . CP.Pixel a => CP.Image a -> CP.Image a) -> CP.DynamicImage -> CP.DynamicImage
withDynamicImage f = go
  where
    go (CP.ImageY8     img) = CP.ImageY8     (f img)
    go (CP.ImageY16    img) = CP.ImageY16    (f img)
    go (CP.ImageY32    img) = CP.ImageY32    (f img)
    go (CP.ImageYF     img) = CP.ImageYF     (f img)
    go (CP.ImageYA8    img) = CP.ImageYA8    (f img)
    go (CP.ImageYA16   img) = CP.ImageYA16   (f img)
    go (CP.ImageRGB8   img) = CP.ImageRGB8   (f img)
    go (CP.ImageRGB16  img) = CP.ImageRGB16  (f img)
    go (CP.ImageRGBF   img) = CP.ImageRGBF   (f img)
    go (CP.ImageRGBA8  img) = CP.ImageRGBA8  (f img)
    go (CP.ImageRGBA16 img) = CP.ImageRGBA16 (f img)
    go (CP.ImageYCbCr8 img) = CP.ImageYCbCr8 (f img)
    go (CP.ImageCMYK8  img) = CP.ImageCMYK8  (f img)
    go (CP.ImageCMYK16 img) = CP.ImageCMYK16 (f img)
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
-----------------------              COORDINATE CONVERSION             -----------------------
----------------------------------------------------------------------------------------------
-- | Convert a position on the game grid to a position on the screen
-- Copied from https://mmhaskell.com/blog/2019/4/1/building-a-bigger-world.
positionToCoords :: (Float, Float) -> (Int, Int) -> C.CPosition -> AG.Point
positionToCoords (xOffset, yOffset) (cellWidth, cellHeight) (C.CPosition (L.V2 x y)) = 
  ( xOffset + fromIntegral x * fromIntegral cellWidth
  , yOffset + fromIntegral y * fromIntegral cellHeight )


positionToCoords' = positionToCoords (0.0, 0.0) (spriteWidth, spriteHeight)
----------------------------------------------------------------------------------------------