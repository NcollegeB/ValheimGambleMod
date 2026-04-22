using System.Collections.Generic;
using Jotunn.Entities;
using Jotunn.Managers;
using UnityEngine;
using System;

namespace GambleMod
{
    public class GambleCommand : ConsoleCommand
    {
        public override string Name => "Gamble";

        public override string Help => "Gamble (amount)    50/50 odds"; // we want 65 35 odds in player favor

        public override void Run(string[] args)
        {

            int wager;

            if (args.Length == 0)
            {
                return;
            }

            if(args.Length > 1)
            {
                // If there are more than 1 arguments, say error only 1 argument is allowed
                Console.instance.Print("Error: Only 1 argument is allowed");
                return;
            }

            if (args.Length == 1)
            {
                bool parseWorked = int.TryParse(args[0], out wager);
                
                if(!parseWorked)
                {
                    Console.instance.Print("Error: Non-integer input");
                    return;
                }

                // get first arg as an integer.
                if (wager <= 0)
                {
                    Console.instance.Print("Error: Cannot Gamble Negative or Zero");
                    return;
                }
                else
                {
                    //instantiate player
                    var player = Player.m_localPlayer;
                    player.GetInventory();

                    // check for coins in inventory
                    if (player.GetInventory().CountItems("$item_coins") >= wager)
                    {
                        // generate number 1-100 inclusive
                        // > 35 succeed -> add wager to inventory
                        // < 50 fail - > take 

                        var rand = new System.Random();

                        int result = rand.Next(0, 100); //inc,excl

                        if(result >= 35)
                        {
                            //success
                            player.GetInventory().AddItem("$item_coins", wager);
                            Console.instance.Print("Win");

                            player.GetInventory().AddItem(item,);
                        }
                        else
                        {
                            //fail
                            player.GetInventory().RemoveItem("$item_coins", wager);
                            Console.instance.Print("Loss");

                        }
                        
                    }
                }
            }

        public override List<string> CommandOptionList()
        {
            return ZNetScene.instance?.GetPrefabNames();
        }
    }
}
