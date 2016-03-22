. C:\DSE\scripts\getMonitorcballey\Monitorcballey.ps1 -ExecutionPolicy RemoteSigned -force

$time = Measure-Command{
Monitorcballey -svr "sushihelix-01.disenza.com" 
Monitorcballey -svr "sushihelix-02.disenza.com" 
Monitorcballey -svr "sushihelix-03.disenza.com" 
Monitorcballey -svr "sushihelix-04.disenza.com" 
Monitorcballey -svr "sushihelix-05.disenza.com" 
Monitorcballey -svr "sushihelix-06.disenza.com" 
Monitorcballey -svr "sushihelix-07.disenza.com" 
Monitorcballey -svr "sushihelix-08.disenza.com" 
Monitorcballey -svr "sushihelix-09.disenza.com" 
Monitorcballey -svr "sushihelix-10.disenza.com" 
Monitorcballey -svr "sushihelix-11.disenza.com" 
Monitorcballey -svr "sushihelix-12.disenza.com" 
}

$time