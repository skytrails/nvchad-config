<!-- 文章编辑弹窗 -->
<template>
  <div>
    <el-drawer
      class="edit-table"
      :title="'实名认证详情'"
      :visible.sync="showDrawer"
      :direction="direction"
      :size="'50%'"
      :before-close="close"
    >
      <el-card shadow="never" style="padding: 30px">
        <div class="operate-container">
          <i class="el-icon-warning color-danger" style="margin-left: 20px"></i>
          <span class="color-danger">当前筹款状态：{{ form.statusName }}</span>
          <div class="operate-button-container" v-show="form.status===1">
            <el-button size="mini" @click="showAuditDialog">审核实名认证</el-button>
          </div>
        </div>
        <div class="table-title">
          <span class="font-small">筹款认证</span>
        </div>
        <div class="table-layout">
          <el-row>
            <el-col :span="6" class="table-cell-title">筹款类型</el-col>
            <el-col :span="6" class="table-cell-title">{{ form.projectType === 1 ? '患者姓名' : '组织机构' }}</el-col>
            <el-col :span="6" class="table-cell-title">筹款金额</el-col>
            <el-col :span="6" class="table-cell-title">申请认证时间</el-col>
          </el-row>
          <el-row>
            <el-col :span="6" class="table-cell">{{ form.projectTypeName }}</el-col>
            <el-col :span="6" class="table-cell">{{
                form.projectType === 1 ? form.patientName : form.organizationName
              }}
            </el-col>
            <el-col :span="6" class="table-cell">{{ form.targetAmount }}</el-col>
            <el-col :span="6" class="table-cell">{{ form.createdAt }}</el-col>
          </el-row>
          <el-row>
            <el-col :span="6" class="table-cell-title">认证人姓名</el-col>
            <el-col :span="6" class="table-cell-title">认证人证件号</el-col>
            <el-col :span="6" class="table-cell-title">手机号</el-col>
            <el-col :span="6" class="table-cell-title">所在地区</el-col>
          </el-row>
          <el-row>
            <el-col :span="6" class="table-cell">{{ form.name }}</el-col>
            <el-col :span="6" class="table-cell">{{ form.idNo }}</el-col>
            <el-col :span="6" class="table-cell">{{ form.phone }}</el-col>
            <el-col :span="6" class="table-cell">{{
                (form.province ? form.province : '') + (form.city ? form.city : '') + (form.district ? form.district : '')
              }}
            </el-col>
          </el-row>
        </div>
        <div class="table-title">
          <span class="font-small">认证人证件照</span>
        </div>
        <div class="table-content table-images">
          <template v-if="form.idImagesList && form.idImagesList.length > 0">
            <el-image class="image-item" v-for="(item, index) in form.idImagesList" :key="index"
                      :src="item"></el-image>
          </template>
          <template v-else>
            <el-empty description="暂无记录"></el-empty>
          </template>
        </div>
      </el-card>
    </el-drawer>
    <!--审核弹窗-->
    <el-dialog title="审核实名认证"
               :visible.sync="auditFormVisible"
               width="40%">
      <el-form ref="auditForm" :model="auditForm" :rules="rules" label-width="100px">
        <el-form-item label="审核结果：">
          <el-radio-group v-model="auditForm.status">
            <el-radio :label="2">通过</el-radio>
            <el-radio :label="3">不通过</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="拒绝原因：">
          <el-input v-model="auditForm.rejectReason" type="textarea" rows="3">
          </el-input>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="auditFormVisible = false">取 消</el-button>
        <el-button type="primary" @click="handleAudit">确 定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import '@riophae/vue-treeselect/dist/vue-treeselect.css';

export default {
  name: 'cfProjectsCertificationDetail',
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 修改回显的数据
    data: Object,
    // 栏目数据
    cateList: Array
  },
  components: {},
  data() {
    return {
      showDrawer: this.visible,
      direction: 'rtl',
      // 表单数据
      form: Object.assign({}, this.data),
      // 表单验证规则
      rules: {
        status: [
          {required: true, message: '请选择审核状态', trigger: 'blur'}
        ],
        sort: [
          {required: true, message: '请输入排序号', trigger: 'blur'}
        ]
      },
      // 提交状态
      loading: false,
      // 是否是修改
      isUpdate: false,
      // 上传目录
      updDir: 'article',

      // 审核弹窗
      auditFormVisible: false,
      auditForm: {status: 0, rejectReason: ''},
    };
  },
  watch: {
    data() {
      if (this.data) {
        this.form = Object.assign({}, this.data);
        this.isUpdate = true;
      } else {
        this.form = {};
        this.isUpdate = false;
      }
    }
  },
  computed: {},
  mounted() {
    this.getInfo();
  },
  methods: {
    /* 获取文章详情 */
    getInfo() {
      if (this.data.id > 0) {
        this.$http.get('/cfProjectsCertification/info/' + this.data.id).then(res => {
          if (res.data.code === 200) {
            this.form = res.data.data;
            this.isUpdate = true;
          } else {
            this.$message.error(res.data.message);
          }
        }).catch(e => {
          this.$message.error(e.message);
        });
      }
    },
    /* 更新visible */
    updateVisible(value) {
      this.$emit('update:visible', value);
    },
    /* 关闭页面 */
    close(hide) {
      if (hide) {
        hide();
      }
      this.$emit("done");
    },
    showAuditDialog() {
      this.auditFormVisible = true;
      this.auditForm.id = this.form.id;
      this.auditForm.status = this.form.status;
    },
    handleAudit() {
      this.$confirm('是否要提交审核?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.$http.post('/cfProjectsCertification/audit', this.auditForm).then(res => {
          if (res.data.code === 200) {
            this.auditFormVisible = false;
            this.getInfo();
            this.$message({
              type: 'success',
              message: res.data.message
            });
          } else {
            this.$message.error(res.data.message);
          }
        }).catch(e => {
          this.$message.error(e.message);
        });
      });
    },
  }
}
</script>

<style scoped>
.operate-container {
  background: #F2F6FC;
  height: 80px;
  /*margin: -20px -20px 0;*/
  line-height: 80px;
  border: 1px solid #DCDFE6;
}

.operate-button-container {
  float: right;
  margin-right: 20px
}

.table-title {
  margin-top: 25px;
  font-weight: bold;
}

.table-layout {
  margin-top: 15px;
  border-left: 1px solid #DCDFE6;
  border-top: 1px solid #DCDFE6;
}

.table-content {
  margin-top: 15px;
}

.table-cell {
  height: 60px;
  line-height: 40px;
  border-right: 1px solid #DCDFE6;
  border-bottom: 1px solid #DCDFE6;
  padding: 10px;
  font-size: 14px;
  color: #606266;
  text-align: center;
  overflow: hidden;
}

.table-cell-title {
  border-right: 1px solid #DCDFE6;
  border-bottom: 1px solid #DCDFE6;
  padding: 10px;
  background: #F2F6FC;
  text-align: center;
  font-size: 14px;
  color: #303133;
}

.table-images {
  display: flex;
  flex-wrap: wrap;
}

.table-images .image-item {
  width: 160px;
  height: 160px;
  margin-right: 15px;
  margin-bottom: 15px;
}

.table-content >>> .el-empty {
  flex: 1;
  padding: 0;
}

.table-content >>> .el-empty__image {
  height: 120px;
}
</style>
