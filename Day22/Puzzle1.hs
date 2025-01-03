module Main where
import Data.Bits

generateSecretNumbers :: Int -> Int -> Int
generateSecretNumbers 0 n = n
generateSecretNumbers i n = generateSecretNumbers (i - 1) n'''
    where n' = (n * 64 `xor` n) `mod` 16777216
          n'' = (n' `div` 32 `xor` n') `mod` 16777216
          n''' = (n'' * 2048 `xor` n'') `mod` 16777216

main :: IO ()
main = do
    content <- readFile "input.txt"
    let secrets = map read $ lines content :: [Int]
        newSecrets = map (generateSecretNumbers 2000) secrets
    print $ sum newSecrets
