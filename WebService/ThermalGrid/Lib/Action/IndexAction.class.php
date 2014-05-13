<?php
class IndexAction extends Action {
    public function index(){
		header("Content-Type:text/html; charset=utf-8");
		header("Cache-Control: no-cache");
		if (!empty($_REQUEST["last"])) {
			return $this->last(intval($_REQUEST["last"]));
		} else 
		if (!empty($_REQUEST["str"])) {
			return $this->insert($_REQUEST["str"]); 
		} else
		if (!empty($_REQUEST["add"])) {
			return $this->insert($_REQUEST["add"]); 
		} else
		if (!empty($_REQUEST["set"])) {
			return $this->set($_REQUEST["set"]); 
		} else
		if (!empty($_REQUEST["get"])) {
			return $this->get(); 
		} else
		if (!empty($_REQUEST["ratio"])) {
			return $this->ratio($_REQUEST["ratio"]); 
		} 

		$Grid = M('grid'); 
		$grids = $Grid->order('time desc')->limit(1)->select(); 
		 
		$this->assign("grids", $grids[0]['str'] );
		$this->display("Index:index");
	}

	public function last($lastn){
		$Grid = M('grid'); 
		$grids = $Grid->order('time desc')->limit($lastn)->select(); 
		echo( $grids[0]['str'] ); 
		return strval($grids[$lastn]['str']); 
	}

	public function insert($word){
		if (strlen($word) == 35) {
			$Grid = M('grid'); 
			$data = array(); 
			$data['str'] = $word; 
			$Grid->add($data); 
			//echo(strval($word)); 
			return get(); 
		} else {
		}
		return $word; 
	}

	public function set($thres) {
		$Thres = M('thres');
		$Thres->where('id = 1')->setField('thres', intval($thres)); 
		$ans = $Thres->select(); 
		dump($ans[0]['thres']); 
		return; 
	}

	public function ratio($ratio) {
		$Thres = M('thres');
		$Thres->where('id = 1')->setField('ratio', intval($ratio)); 
		$ans = $Thres->select(); 
		dump($ans[0]['ratio']); 
		return; 
	}

	public function get() {
		$Thres = M('thres');
		$ans = $Thres->select(); 
		echo $ans[0]['thres']; 
		return; 
	}
}

