using Jotunn.Entities;
using Jotunn.Managers;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace GambleMod
{
    public class GambleCommand : ConsoleCommand
    {
        public override string Name => "Gamble";

        public override string Help => "Gamble (amount)    60 % win chance / 40 loss chance / 1% 10x jackpot / 1% 0x Critical Failure (can be changed in config)"; // we want 65 35 odds in player favor

        public override void Run(string[] args)
        {

            int wager;

            int odds = 40;

            var rand = new System.Random();

            int jackpotNum = 99;

            int lossNum = 0;

            if (args.Length == 0)
            {
                return;
            }

            if (args.Length > 1)
            {
                // If there are more than 1 arguments, say error only 1 argument is allowed
                Console.instance.Print("Error: Only 1 argument is allowed");
                return;
            }

            if (args.Length == 1)
            {
                bool parseWorked = int.TryParse(args[0], out wager);

                if (!parseWorked)
                {
                    Console.instance.Print("Error: Non-integer input");
                    return;
                }

                
                if (wager <= 0)
                {
                    Console.instance.Print("Error: Cannot Gamble Negative or Zero");
                    return;
                }
                else
                {
                    //instantiate player
                    var player = Player.m_localPlayer;

                    // check for coins in inventory
                    if (player.GetInventory().CountItems("$item_coins") >= wager)
                    {
                        // generate number 1-100 inclusive
                        // > 35 succeed -> add wager to inventory
                        // < 50 fail - > take 

                        int result = rand.Next(0, 100); //inc,excl

                        Inventory inv = player.GetInventory();

                        var coinItem = inv.GetItem("$item_coins");
                        var coinPrefab = coinItem?.m_dropPrefab;

                        if (result == lossNum) // 0
                        {
                            inv.RemoveItem("$item_coins", wager);
                            Console.instance.Print("Rolled a - " + result + "\nCritical Failure, lost " + wager + " coins");

                        }
                        else if(result == jackpotNum) // 99
                        {
                            int winAmount = wager * 10;
                            inv.AddItem(coinPrefab, winAmount);
                            Console.instance.Print("WINNER 10x JACKPOT: WON " + winAmount + " Coins!\n rolled a - " + result);
                        }
                        else if (result >= odds) // # >= 40
                        {

                            //success
                            inv.AddItem(coinPrefab, wager);
                            Console.instance.Print("Rolled a - " + result + "\nWon " + wager + " coins");
                        }
                        else if(result < odds) // # < 35
                        {
                            //fail
                            inv.RemoveItem("$item_coins", wager);
                            Console.instance.Print("Rolled a - " + result + "\nLost " + wager + " coins");

                        }

                    }
                    else
                    {
                        Console.instance.Print("Error: Not enough coins aka poor");
                    }
                }
            }
        }
    }
}
