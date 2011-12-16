package tink.macro.build;

import haxe.macro.Expr;
import tink.macro.tools.ExprTools;

/**
 * ...
 * @author back2dos
 */
using tink.macro.tools.ExprTools;

class Constructor {
	var oldStatements:Array<Expr>;
	var nuStatements:Array<Expr>;
	var args:Array<FunctionArg>;
	var pos:Position;
	public var isPublic:Bool;
	public function new(f:Function, ?isPublic:Null<Bool> = null, ?pos:Position) {
		this.nuStatements = [];
		this.isPublic = isPublic;
		this.pos = pos.getPos();
		
		if (f == null) {
			this.args = [];
			this.oldStatements = [];
		}
		else {
			this.args = f.args;
			this.oldStatements =
				if (f.expr == null) [];
				else
					switch (f.expr.expr) {
						case EBlock(exprs): exprs;
						default: oldStatements = [f.expr]; 
					}
		}
	}
	public function init(name:String, pos:Position, ?e:Expr, ?def:Expr) {
		if (e == null) {
			e = name.resolve(pos);
			args.push( { name : name, opt : def != null, type : null, value : def } );
			if (isPublic == null) isPublic = true;
		}
		this.nuStatements.push(['this', name].drill(pos).assign(e, pos));
	}
	public function toBlock() {
		return nuStatements.concat(oldStatements).toBlock(pos);
	}
	public function toHaxe() {
		return {
			name: 'new',
			doc : null,
			access : isPublic ? [APublic] : [],
			kind :  FFun( {
				args:this.args,
				ret:null,
				expr: toBlock(),
				params: []
			}),
			pos : pos,
			meta : []
		}
	}
}