package com.upgrage.util {
   
   public class Queue 
   {
      private var q:Array = [];
      public var length:int = 0;
      
      
      public function Queue() { }
      
      public function write(d:*):void { q[q.length] = d; length++; }
      
      public function read():* 
      {
        if (empty)
        {
          return  null;
        }
        else
        {
          length--;
          return q.shift(); 
        }
      }

      public function get empty():Boolean { return (length <= 0); }
      
      public function spy():* {return (empty) ? null : q[0];}
   }
}