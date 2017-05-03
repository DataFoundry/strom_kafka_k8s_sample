<?php

date_default_timezone_set('UTC');

class Zones {

  function __construct($path) {
    $this->path = $path;
  }

  function list_zones() {
    if (!is_dir($this->path)) {
      return array();
    }
    $zones = scandir($this->path);
    $zones = array_filter($zones, function($x) {
      return ! preg_match("/^\./", $x);
    });
    sort($zones);
    return $zones;
  }

  private function get_zone_file($name) {
    return $this->path . DIRECTORY_SEPARATOR . $name;
  }

  function get_zone($name) {
    $file = $this->get_zone_file($name);
    if (!file_exists($file)) {
      return array();
    }
    $content = file_get_contents($file);
    $content = explode("\n", $content);
    $content = array_filter($content, function($x) {
      return $x != "" && ! preg_match("/^\\s*#/", $x);
    });
    $map = array();
    foreach($content as $x) {
      $s = explode(" ", $x);
      $ip = array_shift($s);
      $result = array();
      foreach($s as $ss) {
        if ($ss != "") {
          array_push($result, $ss);
        }
      }
      if (isset($map[$ip])) {
        $result = array_merge($result, $map[$ip]);
      }
      sort($result);
      $map[$ip] = $result;
    }
    return $map;
  }

  function delete_zone($name) {
    $file = $this->get_zone_file($name);
    if (!file_exists($file)) {
      return false;
    }
    return unlink($file);
  }

  private function dump_zone($file, $map) {
    $s = "# File generated by dnsmasq-rest-api, at ".date('r');
    $s .= "\n\n";
    foreach(array_keys($map) as $k) {
      $s .= $k;
      foreach($map[$k] as $kk) {
        $s .= " ".$kk;
      }
      $s .= "\n";
    }
    return @file_put_contents($file, $s);
  }

  function add_record($name, $ip, $alias) {
    $file = $this->get_zone_file($name);
    $z = $this->get_zone($name);
    if (!isset($z[$ip])) {
      $z[$ip] = array();
    }
    if (!in_array($alias, $z[$ip])) {
      array_push($z[$ip], $alias);
    }
    return $this->dump_zone($file, $z);
  }

  function set_zone($name, $z) {
    $file = $this->get_zone_file($name);
    return $this->dump_zone($file, $z);
  }

  function delete_record($name, $ip, $alias = null) {
    $file = $this->get_zone_file($name);
    $z = $this->get_zone($name);
    if (isset($z[$ip])) {
      if ($alias == null) {
        unset($z[$ip]);
      }
      else {
        $n = array();
        foreach($z[$ip] as $a) {
          if ($a !== $alias) {
            array_push($n, $a);
          }
        }
        if (count($n) == 0) {
          unset($z[$ip]);
        }
        else {
          $z[$ip] = $n;
        }
      }
    }
    return $this->dump_zone($file, $z);
  }

}

