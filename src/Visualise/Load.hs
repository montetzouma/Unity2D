-- | Functions for loading any images used in the game.
-- N.B.: The top left sprite in the sheet has coordinate (0,0).

module Visualise.Load (
  createPictureBundle,
  -- TODO: Remove after testing.
  loadPlayerHurt,
  loadVampireAttack,
  loadZombieAttack,
)
where

import Visualise.Tools (cropDynamicImage, fromDynamicImage', readImage')

import qualified Apecs.Gloss   as AG
import qualified Codec.Picture as CP
import qualified Data.Map      as Map 

import qualified Components    as C


----------------------------------------------------------------------------------------------
-----------------------                GLOBAL VARIABLES                -----------------------
----------------------------------------------------------------------------------------------
spriteSheetPath :: FilePath
spriteSheetPath = "assets/sprites/Scavengers_SpriteSheet.png"
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
-----------------------                   LOAD IMAGES                  -----------------------
----------------------------------------------------------------------------------------------
createPictureBundle :: IO C.CPictureBundle
createPictureBundle = do 
  spriteSheet <- loadSpriteSheet

  let damagedWalls = loadInnerWallsDamaged spriteSheet
      exit         = loadExit spriteSheet
      floor        = loadFloorTiles spriteSheet
      fruit        = loadFruit spriteSheet
      intactWalls  = loadInnerWallsIntact spriteSheet
      outerWalls   = loadOuterWallTiles spriteSheet
      soda         = loadSoda spriteSheet
      playerAttack = loadPlayerAttack spriteSheet
      playerIdle   = loadPlayerIdle spriteSheet
      vampireIdle  = loadVampireIdle spriteSheet
      zombieIdle   = loadZombieIdle spriteSheet

  let damagedWalls' = Map.fromList $ zip [minBound .. maxBound] damagedWalls
      floor'        = Map.fromList $ zip [minBound .. maxBound] floor
      outerWalls'   = Map.fromList $ zip [minBound .. maxBound] outerWalls
      intactWalls'  = Map.fromList $ zip [minBound .. maxBound] intactWalls

  let picBundle = C.CPictureBundle
        { C.damagedInnerWallPics = damagedWalls'
        , C.exitPic              = exit
        , C.floorPics            = floor'
        , C.fruitPic             = fruit
        , C.intactInnerWallPics  = intactWalls'
        , C.outerWallPics        = outerWalls'
        , C.playerAttackPics     = playerAttack
        , C.playerIdlePics       = playerIdle
        , C.sodaPic              = soda
        , C.vampireIdlePics      = vampireIdle 
        , C.zombieIdlePics       = zombieIdle
        }

  return picBundle


loadSpriteSheet :: IO CP.DynamicImage
loadSpriteSheet = readImage' spriteSheetPath


loadExit  = loadPic' (4,2)


loadFloorTiles = loadPics'
  [ (0, 4)
  , (1, 4)
  , (2, 4)
  , (3, 4)
  , (4, 4)
  , (5, 4)
  , (6, 4)
  , (7, 4) ]


loadFruit = loadPic' (3,2)


loadInnerWallsDamaged = loadPics'
  [ (0, 6)
  , (1, 6)
  , (2, 6)
  , (3, 6)
  , (4, 6)
  , (5, 6) 
  , (6, 6) ]

loadInnerWallsIntact = loadPics'
  [ (5, 2)
  , (6, 2)
  , (7, 2)
  , (0, 3)
  , (3, 3)
  , (6, 3) 
  , (7, 3) ]


loadOuterWallTiles = loadPics' 
  [ (1, 3)
  , (2, 3)
  , (4, 3) ]


loadPlayerAttack = loadPics' 
  [ (0, 5)
  , (1, 5) ]

loadPlayerHurt = loadPics' 
  [ (6, 5)
  , (7, 5) ]

loadPlayerIdle = loadPics' 
  [ (0, 0)
  , (1, 0)
  , (2, 0)
  , (3, 0)
  , (4, 0)
  , (5, 0) ]


loadSoda  = loadPic' (2,2)


loadVampireAttack = loadPics' 
  [ (4, 5)
  , (5, 5) ]
  
loadVampireIdle = loadPics' 
  [ (4, 1)
  , (5, 1)
  , (6, 1)
  , (7, 1)
  , (0, 2)
  , (1, 2) ]


loadZombieAttack = loadPics' 
  [ (2, 5)
  , (3, 5) ]

loadZombieIdle = loadPics'
  [ (6, 0)
  , (7, 0)
  , (0, 1)
  , (1, 1)
  , (2, 1)
  , (3, 1) ]
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
-----------------------                GENERAL FUNCTIONS               -----------------------
----------------------------------------------------------------------------------------------
loadPic' :: (Int, Int) -> CP.DynamicImage -> AG.Picture 
loadPic' = loadPic C.spriteWidth C.spriteHeight


loadPic :: Int -> Int -> (Int, Int) -> CP.DynamicImage -> AG.Picture 
loadPic cellWidth cellHeight (row, col) img = croppedPic 
  where
    x = row * cellWidth
    y = col * cellHeight
    croppedImg = cropDynamicImage x y cellWidth cellHeight img
    croppedPic = fromDynamicImage' croppedImg


loadPics' :: [(Int, Int)] -> CP.DynamicImage -> [AG.Picture]
loadPics' = loadPics C.spriteWidth C.spriteHeight


loadPics :: Int -> Int -> [(Int, Int)] -> CP.DynamicImage -> [AG.Picture]
loadPics cellWidth cellHeight rowsCols img = map (\rc -> loadPic cellWidth cellHeight rc img) rowsCols
----------------------------------------------------------------------------------------------